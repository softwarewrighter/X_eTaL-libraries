#!/usr/bin/env -S uv run python3
"""Check first-view scenes in a real browser using the stdlib WebDriver client."""
import argparse
import base64
import json
from pathlib import Path
import shutil
import time
from urllib.request import Request, urlopen

ROOT = Path(__file__).resolve().parent.parent
ELEMENT = "element-6066-11e4-a52e-4f735466cecf"


def check(base, driver, binary=None, max_preview_ms=2000):
    def request(method, path, data=None):
        body = None if data is None else json.dumps(data).encode()
        req = Request(driver + path, data=body, method=method, headers={"Content-Type": "application/json"})
        with urlopen(req, timeout=180) as response:
            value = json.load(response)["value"]
        if isinstance(value, dict) and "error" in value:
            raise RuntimeError(value)
        return value

    chrome = {"args": ["--headless=new", "--no-sandbox", "--disable-dev-shm-usage", "--window-size=1440,1000"]}
    binary = binary or shutil.which("chromium") or shutil.which("google-chrome")
    if binary:
        chrome["binary"] = binary
    session = request("POST", "/session", {"capabilities": {"alwaysMatch": {
        "browserName": "chrome", "goog:chromeOptions": chrome}}})["sessionId"]
    prefix = f"/session/{session}"
    output = ROOT / "work/browser-scenes"
    output.mkdir(parents=True, exist_ok=True)

    def js(script, *args):
        return request("POST", prefix + "/execute/sync", {"script": script, "args": args})

    def wait(script):
        deadline = time.monotonic() + 60
        while time.monotonic() < deadline:
            if js(script):
                return
            time.sleep(.2)
        raise AssertionError("browser condition timed out: " + script)

    def click(selector):
        element = request("POST", prefix + "/element", {"using": "css selector", "value": selector})
        request("POST", prefix + f"/element/{element[ELEMENT]}/click", {})

    def button(text):
        element = js("return [...document.querySelectorAll('button')].find(b => b.textContent.trim() === arguments[0])", text)
        request("POST", prefix + f"/element/{element[ELEMENT]}/click", {})

    def navigate(fragment=""):
        request("POST", prefix + "/url", {"url": base + fragment})
        wait("return document.querySelector('h1') !== null")

    def screenshot(name):
        data = request("GET", prefix + "/screenshot")
        (output / f"{name}.png").write_bytes(base64.b64decode(data))

    def reference_visible():
        wait("return document.querySelector('.reference-preview img')?.naturalWidth >= 640")
        assert js("const r=document.querySelector('.reference-preview img').getBoundingClientRect(); return r.width>280 && r.top>=0 && r.bottom<=innerHeight"), "full native preview visible above the fold"
        assert not js("return document.querySelector('.reference-preview svg') !== null"), "no blocky initial SVG"

    try:
        request("POST", prefix + "/window/rect", {"width": 1440, "height": 1000})
        navigate()
        wait("return [...document.querySelectorAll('.scene-gallery img')].filter(i=>i.naturalWidth>=640).length === 4")
        assert js("const r=document.querySelector('.scene-gallery img').getBoundingClientRect(); return r.bottom<=innerHeight && r.width>=600"), "landing hero visible immediately"
        screenshot("desktop-home")
        timings = {}
        for name in ("Glass/example", "Scene/logo", "RayTrace/diagnostic", "Extrusion/logo"):
            navigate("#" + name)
            lib, demo = name.split("/")
            wait(f"return document.querySelector('section > h2')?.textContent.startsWith({json.dumps(lib)}) && document.querySelector('.chip.current')?.textContent === {json.dumps(demo + '.xtl')}")
            reference_visible()
            before = js("return document.querySelector('.reference-preview img').src")
            elapsed = request("POST", prefix + "/execute/async", {
                "script": "const done=arguments[arguments.length-1]; const start=performance.now(); document.querySelector('button.run').click(); requestAnimationFrame(()=>requestAnimationFrame(()=>done(performance.now()-start)));",
                "args": []})
            wait("return document.querySelector('.quick-output svg') !== null && document.querySelector('.run-timing') !== null")
            assert js("return document.querySelector('.reference-preview img').src") == before, "default Run preserves the presentation"
            timings[name] = round(elapsed, 1)
            print(f"ok: actual default {name}: {elapsed:.0f} ms click-to-paint; " + js("return document.querySelector('.run-timing').textContent"), flush=True)
        (output / "preview-latency.json").write_text(json.dumps(timings, indent=2) + "\n")
        slow = {name: ms for name, ms in timings.items() if ms >= max_preview_ms}
        assert not slow, f"actual default previews exceed {max_preview_ms:.0f} ms: {slow}"
        navigate("#Glass/example")
        wait("return document.querySelector('.chip.current')?.textContent === 'example.xtl'")
        reference_visible()
        screenshot("desktop-glass-example")
        navigate("#Glass/lens-area")
        wait("return document.querySelector('.chip.current')?.textContent === 'example.xtl'")
        reference_visible()
        navigate("#Glass")
        wait("return document.querySelector('.chip.current')?.textContent === 'example.xtl'")
        reference_visible()
        screenshot("desktop-glass")
        navigate("#Glass/cap-convergence")
        wait("return document.querySelector('.preview-label a')?.textContent === 'example.xtl'")
        reference_visible()
        assert js("return !document.querySelector('.program-source').open"), "diagnostic source starts collapsed"
        navigate("#RayTrace")
        wait("return document.querySelector('.chip.current')?.textContent === 'diagnostic.xtl'")
        reference_visible()
        before = js("return document.querySelector('.reference-preview img').src")
        button("Edit")
        tiny = '"rt:" u_se< "RayTrace"\npicture := 2 2 rt:s_how! 4 3 r_eshape 1.0 0.0 0.0 0.0 1.0 0.0 0.0 0.0 1.0 1.0 1.0 1.0\n'
        js("const a=document.querySelector('textarea.editor'); Object.getOwnPropertyDescriptor(HTMLTextAreaElement.prototype,'value').set.call(a,arguments[0]); a.dispatchEvent(new InputEvent('input',{bubbles:true}));", tiny)
        button("Run small test")
        wait("return document.querySelector('.quick-output svg') !== null")
        assert not js("return document.querySelector('.quick-output').open"), "small render is opt-in"
        assert js("return document.querySelector('.reference-preview img').src") == before, "Run keeps the antialiased reference"
        js("window.scrollTo(0,0)")
        screenshot("desktop-after-run")
        click(".quick-output summary")
        assert js("return document.querySelector('.quick-output').open"), "quick result can be inspected"
        button("Reset")
        wait("return !document.querySelector('.quick-output') && !document.querySelector('.program-source').open")
        reference_visible()
        button("Edit")
        navigate("#Glass/example")
        wait("return document.querySelector('.chip.current')?.textContent === 'example.xtl' && !document.querySelector('.program-source').open")
        reference_visible()
        print("ok: desktop gallery, preferred scenes, explicit diagnostics, Run/Reset", flush=True)

        request("POST", prefix + "/window/rect", {"width": 390, "height": 844})
        navigate()
        wait("return document.querySelector('.scene-gallery img')?.naturalWidth >= 640")
        assert js("return getComputedStyle(document.querySelector('.library-list')).display === 'none'"), "mobile navigation starts compact"
        assert js("const r=document.querySelector('.scene-gallery img').getBoundingClientRect(); return r.width>280 && r.bottom<=innerHeight"), "mobile hero visible without scrolling"
        assert js("return document.documentElement.scrollWidth <= innerWidth+1"), "no mobile horizontal overflow"
        screenshot("mobile-home")
        click(".scene-card")
        reference_visible()
        screenshot("mobile-logo")
        click(".library-toggle")
        element = js("return [...document.querySelectorAll('nav li')].find(li => li.querySelector('.name')?.textContent === 'Glass')")
        request("POST", prefix + f"/element/{element[ELEMENT]}/click", {})
        wait("return document.querySelector('.chip.current')?.textContent === 'example.xtl'")
        assert js("return document.querySelector('.library-toggle').getAttribute('aria-expanded') === 'false'"), "selection closes menu"
        reference_visible()
        screenshot("mobile-glass")
        print("ok: mobile first view, gallery links, compact navigation and preferred glass", flush=True)
        print(f"screenshots: {output}", flush=True)
    finally:
        request("DELETE", prefix)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--url", default="http://127.0.0.1:8459/X_eTaL-libraries/")
    parser.add_argument("--driver", default="http://127.0.0.1:9461")
    parser.add_argument("--browser", help="Chrome/Chromium binary, otherwise detected or chosen by ChromeDriver")
    parser.add_argument("--max-preview-ms", type=float, default=2000, help="actual unedited default preview budget (default 2000 ms)")
    args = parser.parse_args()
    check(args.url, args.driver, args.browser, args.max_preview_ms)
