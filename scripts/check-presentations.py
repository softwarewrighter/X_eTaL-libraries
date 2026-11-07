#!/usr/bin/env -S uv run python3
"""Check recorded presentation pixels/provenance without rerendering large frames."""
import argparse
import base64
import importlib.util
import json
import os
from pathlib import Path
import re
import struct
import subprocess
import tempfile
import zlib

ROOT = Path(__file__).resolve().parent.parent
spec = importlib.util.spec_from_file_location("presentation", ROOT / "scripts/presentation-scenes.py")
renderer = importlib.util.module_from_spec(spec)
spec.loader.exec_module(renderer)


def decode(image):
    assert image[:8] == b"\x89PNG\r\n\x1a\n", "PNG signature"
    position, packed, dimensions, ended = 8, bytearray(), None, False
    while position < len(image):
        length = struct.unpack(">I", image[position:position + 4])[0]
        kind = image[position + 4:position + 8]
        payload = image[position + 8:position + 8 + length]
        crc = struct.unpack(">I", image[position + 8 + length:position + 12 + length])[0]
        assert zlib.crc32(kind + payload) == crc, "PNG CRC"
        if kind == b"IHDR":
            width, height, depth, color, compression, filtering, interlace = struct.unpack(">IIBBBBB", payload)
            assert (depth, color, compression, filtering, interlace) == (8, 2, 0, 0, 0), "RGB8 PNG layout"
            dimensions = width, height
        elif kind == b"IDAT":
            packed.extend(payload)
        elif kind == b"IEND":
            assert position + 12 == len(image), "PNG trailing data"
            ended = True
            break
        position += length + 12
    assert dimensions is not None and ended, "complete PNG"
    width, height = dimensions
    rows = zlib.decompress(packed)
    stride = width * 3 + 1
    assert len(rows) == height * stride, "PNG payload size"
    assert all(rows[i] == 0 for i in range(0, len(rows), stride)), "unfiltered recorded PNG rows"
    return width, height, b"".join(rows[i + 1:i + stride] for i in range(0, len(rows), stride))


def check(require_all=False):
    pin = (ROOT / "XETAL_COMMIT").read_text().strip()
    for scene, (width, height, axis) in renderer.SCENES.items():
        lib, demo = scene.split("/")
        prefix = ROOT / f"libs/{lib}/docs/presentation-{demo}"
        if not prefix.with_suffix(".json").exists():
            assert not require_all, f"{scene}: presentation render is pending"
            assert not prefix.with_suffix(".html").exists(), f"{scene}: missing provenance"
            print(f"pending: {scene}: offline render not yet recorded")
            continue
        meta = json.loads(prefix.with_suffix(".json").read_text())
        html = prefix.with_suffix(".html").read_text()
        encoded = re.search(r'src="data:image/png;base64,([A-Za-z0-9+/=]+)"', html)
        assert encoded, f"{scene}: embedded PNG"
        image = base64.b64decode(encoded[1], validate=True)
        actual_width, actual_height, pixels = decode(image)
        assert (actual_width, actual_height) == (width, height), f"{scene}: native resolution"
        assert (meta["width"], meta["height"], meta["samples_per_pixel"]) == (width, height, axis**2), f"{scene}: quality settings"
        assert f"{width} x {height}, {axis**2} samples per pixel." in html, f"{scene}: quality caption"
        assert meta["png_sha256"] == renderer.digest(image), f"{scene}: PNG hash"
        assert meta["xetal"] == pin, f"{scene}: language provenance"
        for dependency in renderer.dependencies(scene):
            assert meta["library_sources"][str(dependency.relative_to(ROOT))] == renderer.digest(dependency.read_bytes()), f"{scene}: dependency provenance: {dependency.name}"
        assert meta["source_sha256"] == renderer.digest((ROOT / f"libs/{lib}/demos/{demo}.xtl").read_bytes()), f"{scene}: demo provenance"
        assert meta["renderer_sha256"] == renderer.digest((ROOT / "scripts/presentation-scenes.py").read_bytes()), f"{scene}: renderer provenance"
        next_pixel = 0
        for chunk in meta["chunks"]:
            assert chunk["first"] == next_pixel and chunk["count"] > 0, f"{scene}: contiguous pixel coverage"
            count = chunk["count"]
            source = renderer.program(scene, width, height, axis, next_pixel, count)
            assert chunk["source_sha256"] == renderer.digest(source.encode()), f"{scene}: chunk source"
            assert chunk["rgb_sha256"] == renderer.digest(pixels[next_pixel * 3:(next_pixel + count) * 3]), f"{scene}: chunk pixels"
            assert chunk["key"] == renderer.digest((pin + meta["libraries_sha256"] + source).encode()), f"{scene}: chunk dependencies"
            next_pixel += count
        assert next_pixel == width * height, f"{scene}: complete frame"
        print(f"ok: {scene}: {width}x{height}, {axis**2} samples/pixel")


def self_test():
    # Real rays cross geometry: compare whole batches with independent chunks.
    # No host shader or image resampling participates in either calculation.
    env = dict(os.environ, XETAL_PATH=":".join(str(p) for p in sorted((ROOT / "libs").glob("*/src"))))
    with tempfile.TemporaryDirectory() as scratch:
        def execute(scene, first, count):
            path = Path(scratch) / "chunk.xtl"
            path.write_text(renderer.program(scene, 16, 12, 2, first, count))
            run = subprocess.run([str(ROOT / "bin/xetal"), "run", "--seed", "1", "--ascii", str(path)],
                                 env=env, capture_output=True, text=True, check=True, timeout=300)
            return [float(x) for x in run.stdout.split("PRESENTATION RGB\n", 1)[1].split()]
        for scene in ["RayTrace/diagnostic", "Glass/example", "Glass/lens-area"]:
            together = execute(scene, 84, 8)
            divided = execute(scene, 84, 3) + execute(scene, 87, 5)
            assert together == divided, f"{scene}: pixel/sample identities changed across chunks"
            assert len(together) == 24 and len(set(together)) > 1, f"{scene}: nontrivial RGB fixture"
            print(f"ok: chunk invariance: {scene}")
    fixture = bytes([0, 127, 255, 255, 0, 32])
    assert decode(renderer.png(2, 1, fixture)) == (2, 1, fixture), "lossless PNG encoding"
    print("ok: lossless RGB8 PNG")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--self-test", action="store_true")
    parser.add_argument("--require-all", action="store_true", help="require all configured offline renders before final completion")
    options = parser.parse_args()
    if options.self_test:
        self_test()
    else:
        check(options.require_all)
