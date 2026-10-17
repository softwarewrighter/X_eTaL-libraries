//! Output that is math: a line of a program's output written between
//! `$$` is LaTeX, drawn by KaTeX (vendored in katex/); the rest is text.

use wasm_bindgen::prelude::*;

/// A line of a program's output.
#[derive(Debug, PartialEq, Eq)]
pub enum Line<'a> {
    Text(&'a str),
    /// The LaTeX between the `$$`.
    Math(&'a str),
}

/// The output split into lines, each text or math.
pub fn lines(out: &str) -> Vec<Line<'_>> {
    out.lines()
        .map(|line| {
            let t = line.trim();
            match t.strip_prefix("$$").and_then(|r| r.strip_suffix("$$")) {
                Some(tex) if t.len() >= 4 => Line::Math(tex.trim()),
                _ => Line::Text(line),
            }
        })
        .collect()
}

#[wasm_bindgen]
extern "C" {
    #[wasm_bindgen(js_namespace = katex, js_name = renderToString, catch)]
    fn render_to_string(tex: &str, options: &JsValue) -> Result<String, JsValue>;
}

/// The HTML KaTeX draws for `tex` in display mode; the LaTeX itself,
/// escaped, when KaTeX is missing or rejects it.
pub fn html(tex: &str) -> String {
    let options = js_sys::Object::new();
    let _ = js_sys::Reflect::set(&options, &"displayMode".into(), &true.into());
    let _ = js_sys::Reflect::set(&options, &"throwOnError".into(), &false.into());
    render_to_string(tex, &options).unwrap_or_else(|_| escaped(tex))
}

/// `text` safe inside HTML text or a quoted attribute.
pub fn escaped(text: &str) -> String {
    text.replace('&', "&amp;")
        .replace('<', "&lt;")
        .replace('>', "&gt;")
        .replace('"', "&quot;")
}
