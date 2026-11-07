#!/usr/bin/env -S uv run python3
"""Render presentation images in bounded, resumable native X_eTaL chunks."""
import argparse
import base64
from concurrent.futures import ThreadPoolExecutor, as_completed
import hashlib
import json
import math
import os
from pathlib import Path
import re
import struct
import subprocess
import time
import zlib

ROOT = Path(__file__).resolve().parent.parent
SCENES = {"Scene/logo": (640, 320, 2), "Extrusion/logo": (800, 200, 2),
          "RayTrace/diagnostic": (640, 426, 2),
          "Glass/lens-area": (640, 480, 8)}


def digest(data):
    return hashlib.sha256(data).hexdigest()


def dependencies(scene):
    """Local imports, including macro-generated imports; stdlib follows the pin."""
    lib, demo = scene.split("/")
    pending = [ROOT / f"libs/{lib}/demos/{demo}.xtl"]
    seen, sources = set(), []
    while pending:
        path = pending.pop()
        if path in seen:
            continue
        seen.add(path)
        if path.parent.name == "src":
            sources.append(path)
        for name in re.findall(r'u_se<\s+\\*"([A-Za-z0-9]+)\\*"', path.read_text()):
            for imported in sorted((ROOT / "libs" / name / "src").glob("*.xtl*")):
                pending.append(imported)
    return sorted(sources)


def png(width, height, pixels):
    def chunk(kind, data):
        return struct.pack(">I", len(data)) + kind + data + struct.pack(">I", zlib.crc32(kind + data))
    stride = width * 3
    rows = b"".join(b"\0" + pixels[i:i + stride] for i in range(0, len(pixels), stride))
    return (b"\x89PNG\r\n\x1a\n" + chunk(b"IHDR", struct.pack(">IIBBBBB", width, height, 8, 2, 0, 0, 0))
            + chunk(b"IDAT", zlib.compress(rows, 9)) + chunk(b"IEND", b""))


def program(scene, width, height, axis, first, count, original=None):
    lib, demo = scene.split("/")
    if original is None:
        original = (ROOT / f"libs/{lib}/demos/{demo}.xtl").read_text()
    source = original[:original.index("size :=")]
    if lib == "RayTrace":
        source = source[:source.index("# Row-major")] + source[source.index("# A rendered 3D scene"):]
    spp = axis * axis
    source += f"""
# Offline quality settings; global pixel/sample coordinates survive chunking.
qualitysize := {width} {height}
qualityspp := {spp}
qualitycount := {count}
qualityn := qualitycount * qualityspp
qualitypixels := {first} + ((r_ange qualityn) - 1) d_iv qualityspp
qualitysamples := ((r_ange qualityn) - 1) m_od qualityspp
qualitysquare := o_\\ ((1 c_at qualityn) r_eshape (f_loat qualitysamples m_od {axis}) + 0.5) c_at (1 c_at qualityn) r_eshape (f_loat qualitysamples d_iv {axis}) + 0.5
qualityfilm := qualitysquare / {axis}.0
"""
    camera = {"Scene": "logocamera", "Extrusion": "camera", "RayTrace": "sceneCamera", "Glass": "democamera"}[lib]
    if lib == "Scene":
        source += "\n".join(line for line in original.splitlines() if line.startswith(("clip :=", "environment :="))) + "\n"
    if lib == "Extrusion":
        # These settings occur after size in the quick demo.
        source += original[original.index("camera :="):original.index("origins :=")]
        source += original[original.index("materials :="):original.index("linear :=")]
    source += f"qualitypinhole := ((({camera} rt:r_aysAt qualitysize)_ qualitypixels + 1)_ qualityfilm)\n"
    source += f"qualityeye := {camera} rt:o_rigins qualityn\n"
    if scene == "Glass/lens-area":
        source += """
qualityidentities := o_\\ ((1 c_at qualityn) r_eshape qualitypixels) c_at (1 c_at qualityn) r_eshape qualitysamples
u:c_ounters := { dimension -> o_\\ (o_\\ qualityidentities) c_at ((1 c_at qualityn) r_eshape 4294967295) c_at (1 c_at qualityn) r_eshape dimension }
qualitydisk := r:d_isk o_\\ ((1 c_at qualityn) r_eshape 123 r:s_amples u:c_ounters 2) c_at (1 c_at qualityn) r_eshape 123 r:s_amples u:c_ounters 3
(qualityorigins, qualitydirections) := (((democamera rt:l_ensRays demolens)_ qualitypinhole)_ qualitydisk)
qualitymedium := world gl:m_ediums qualityorigins
qualitylinear := (((((((area gl:r_enderArea 0.00001 100.0 1e-10 0.000001)_ 2 3 r_eshape 0.0 0.0 0.0 0.1 0.15 0.2)_ qualityorigins)_ qualitydirections)_ qualitymedium)_ qualityidentities)_ 123 16)
"""
    elif scene == "Glass/example":
        source += "qualityorigins := qualityeye\nqualitydirections := qualitypinhole\n"
        source += "qualitymedium := imageWorld gl:m_ediums qualityorigins\n"
        source += "qualitykeys := qualitysamples + qualityspp * qualitypixels\n"
        source += "qualitylinear := (((((((imageWorld gl:r_ender clip)_ environment)_ qualityorigins)_ qualitydirections)_ qualitymedium)_ qualitykeys)_ 123 16)\n"
    else:
        source += "qualityorigins := qualityeye\nqualitydirections := qualitypinhole\n"
        args = {"Scene": ("clip", "r_ender", "mesh", "materialids", "materials", "logolights", "environment"),
                "Extrusion": ("1e-6 100.0 1e-10 1e-5", "s_hade", "logotriangles", "(t_ally logotriangles) r_eshape 1", "materials", "lights", "env"),
                "RayTrace": ("clip", "r_ender", "sceneMesh", "sceneIds", "sceneMaterials", "sceneLight", "environment")}[lib]
        clip, fn, mesh, ids, materials, lights, env = args
        source += f"qualitylinear := ((((((({clip} rt:{fn} {mesh})_ {ids})_ {materials})_ {lights})_ {env})_ qualityorigins)_ qualitydirections)\n"
    exposure = {"Scene": 1.3, "Extrusion": 1.3, "RayTrace": 1.5, "Glass": 1.0}[lib]
    source += f"""
qualitymean := ('+ r_/_2 (qualitycount c_at qualityspp c_at 3) r_eshape qualitylinear) / {spp}.0
"PRESENTATION RGB"
r_avel {exposure} rt:s_rgb qualitymean
"""
    return source


def render(args):
    width, height, axis = SCENES[args.scene]
    width = width if args.width is None else args.width
    height = height if args.height is None else args.height
    axis = axis if args.axis is None else args.axis
    if args.chunk is None:
        args.chunk = 128 if args.scene.startswith("Glass/") else 1024
    if min(width, height, axis, args.chunk, args.jobs) < 1:
        raise ValueError("dimensions, sampling, chunks and workers must be positive")
    if args.limit is not None and args.limit < 1:
        raise ValueError("benchmark pixel count must be positive")
    output = ROOT / "work/presentation" / args.scene.replace("/", "-")
    output.mkdir(parents=True, exist_ok=True)
    libraries = sorted((ROOT / "libs").glob("*/src/*xtl*"))
    contents = {p: p.read_bytes() for p in libraries}
    library_hash = digest(b"".join(str(p.relative_to(ROOT)).encode() + data for p, data in contents.items()))
    library_sources = {str(p.relative_to(ROOT)): digest(data) for p, data in contents.items()}
    snapshot = ROOT / "work/presentation/library-snapshots" / library_hash
    for path, data in contents.items():
        target = snapshot / path.relative_to(ROOT)
        target.parent.mkdir(parents=True, exist_ok=True)
        if not target.exists() or target.read_bytes() != data:
            target.write_bytes(data)
    env = dict(os.environ, XETAL_PATH=":".join(str(p) for p in sorted((snapshot / "libs").glob("*/src"))))
    lib, demo = args.scene.split("/")
    demo_source = (ROOT / f"libs/{lib}/demos/{demo}.xtl").read_text()
    pin = (ROOT / "XETAL_COMMIT").read_text().strip()
    start = time.monotonic()
    total = args.limit or width * height
    stop = args.first + total
    if args.first < 0 or stop > width * height:
        raise ValueError("requested pixels must lie within the full frame")

    def one(first):
        count = min(args.chunk, stop - first)
        source = program(args.scene, width, height, axis, first, count, demo_source)
        key = digest((pin + library_hash + source).encode())
        prefix = output / f"{first:08}"
        data, record = prefix.with_suffix(".rgb"), prefix.with_suffix(".json")
        if record.exists() and data.exists():
            try:
                cached = json.loads(record.read_text())
                pixels = data.read_bytes()
                if cached.get("key") == key and len(pixels) == count * 3 and digest(pixels) == cached.get("rgb_sha256"):
                    return first, pixels, cached, True
            except (ValueError, OSError):
                pass  # An interrupted cache record is regenerated.
        prefix.with_suffix(".xtl").write_text(source)
        tick = time.monotonic()
        run = subprocess.run([str(ROOT / "bin/xetal"), "run", "--seed", "1", "--ascii", str(prefix.with_suffix(".xtl"))],
                             env=env, text=True, capture_output=True)
        prefix.with_suffix(".err").write_text(run.stderr)
        if run.returncode:
            raise RuntimeError(f"{args.scene} chunk {first}: {run.stderr}")
        prefix.with_suffix(".out").write_text(run.stdout)
        values = [float(x) for x in run.stdout.split("PRESENTATION RGB\n", 1)[1].split()]
        if len(values) != count * 3 or any(not math.isfinite(v) or not 0 <= v <= 1 for v in values):
            raise ValueError("invalid display RGB output")
        pixels = bytes(int(v * 255 + 0.5) for v in values)
        meta = dict(key=key, first=first, count=count, source_sha256=digest(source.encode()),
                    rgb_sha256=digest(pixels), seconds=time.monotonic() - tick)
        data.write_bytes(pixels)
        temporary = record.with_suffix(".json.tmp")
        temporary.write_text(json.dumps(meta, indent=2) + "\n")
        temporary.replace(record)
        return first, pixels, meta, False

    chunks = []
    print(f"{args.scene}: {width}x{height}, {axis**2} samples/pixel, {args.jobs} workers", flush=True)
    with ThreadPoolExecutor(max_workers=args.jobs) as pool:
        futures = [pool.submit(one, i) for i in range(args.first, stop, args.chunk)]
        for future in as_completed(futures):
            item = future.result()
            chunks.append(item)
            print(f"{len(chunks)}/{len(futures)} chunks; {item[2]['seconds']:.1f}s; {'cached' if item[3] else 'rendered'}", flush=True)
    chunks.sort()
    if args.first or total != width * height:
        return
    pixels = b"".join(c[1] for c in chunks)
    image = png(width, height, pixels)
    lib, demo = args.scene.split("/")
    destination = ROOT / f"libs/{lib}/docs/presentation-{demo}"
    manifest = dict(scene=args.scene, width=width, height=height, samples_per_pixel=axis**2,
                    sample_pattern="centered stratified square film grid; linear RGB averaged in X_eTaL",
                    xetal=pin, libraries_sha256=library_hash, png_sha256=digest(image),
                    library_sources=library_sources,
                    source_sha256=digest(demo_source.encode()),
                    renderer_sha256=digest(Path(__file__).read_bytes()),
                    backend="pinned native X_eTaL evaluator", seed=123, workers=args.jobs,
                    chunk_pixels=args.chunk, invocation_wall_seconds=time.monotonic()-start,
                    cached_chunks=sum(int(c[3]) for c in chunks),
                    executed_chunks=sum(int(not c[3]) for c in chunks),
                    total_recorded_chunk_seconds=sum(c[2]["seconds"] for c in chunks),
                    timing_scope="Invocation wall time includes cache reads; recorded chunk times overlap and are not a serial baseline",
                    chunks=[c[2] for c in chunks])
    (output / "presentation.png").write_bytes(image)
    encoded = base64.b64encode(image).decode("ascii")
    caption = f"{width} x {height}, {axis**2} samples per pixel. Offline antialiased render. Run computes the quick demo below."
    destination.with_suffix(".html").write_text(f'<figure><img width="{width}" height="{height}" alt="{args.scene} rendered scene" src="data:image/png;base64,{encoded}"/><figcaption>{caption}</figcaption></figure>\n')
    destination.with_suffix(".json").write_text(json.dumps(manifest, indent=2) + "\n")
    print(f"recorded {destination}.html", flush=True)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("scene", choices=SCENES)
    parser.add_argument("--width", type=int)
    parser.add_argument("--height", type=int)
    parser.add_argument("--axis", type=int)
    parser.add_argument("--jobs", type=int, default=8)
    parser.add_argument("--chunk", type=int, help="pixels per chunk; default 1024 opaque, 128 glass")
    parser.add_argument("--limit", type=int, help="benchmark only this many pixels without recording an image")
    parser.add_argument("--first", type=int, default=0, help="first global pixel for a bounded benchmark")
    render(parser.parse_args())
