//! Embed every library of ../libs: its name, summary, recommended alias,
//! source, reference page (rendered to HTML), demos and tests' types,
//! as a generated catalog (OUT_DIR/catalog.rs).

use std::fmt::Write as _;
use std::fs;
use std::path::{Path, PathBuf};

const REPO: &str = "https://github.com/softwarewrighter/X_eTaL-libraries/blob/main";

fn main() {
    let libs = Path::new(env!("CARGO_MANIFEST_DIR")).join("../libs");
    println!("cargo:rerun-if-changed={}", libs.display());
    let mut names: Vec<PathBuf> = fs::read_dir(&libs)
        .expect("libs/")
        .flatten()
        .map(|e| e.path())
        .filter(|p| p.join("src").is_dir())
        .collect();
    names.sort();
    let mut out = String::from("pub static LIBRARIES: &[Library] = &[\n");
    for dir in names {
        let name = dir.file_name().unwrap().to_string_lossy().to_string();
        for sub in ["src", "docs", "demos", "tests"] {
            println!("cargo:rerun-if-changed={}", dir.join(sub).display());
        }
        let src = fs::read_to_string(dir.join("src").join(format!("{name}.xtl"))).unwrap_or_default();
        // The header's first line and its continuation, up to the import line.
        let summary = src
            .lines()
            .take_while(|l| !l.contains("u_se<"))
            .map(|l| l.trim_start_matches('#').trim())
            .collect::<Vec<_>>()
            .join(" ");
        let summary = summary.trim_start_matches(&format!("{name}: ")).to_string();
        let alias = src
            .find("\" u_se<")
            .and_then(|end| src[..end].rfind('"').map(|start| src[start + 1..end].to_string()))
            .unwrap_or_default();
        let docs = fs::read_to_string(dir.join("docs/README.md")).unwrap_or_default();
        let docs = html(&name, &docs);
        let types = fs::read_to_string(dir.join("tests/types.out")).unwrap_or_default();
        let mut demos: Vec<PathBuf> = fs::read_dir(dir.join("demos"))
            .map(|d| d.flatten().map(|e| e.path()).filter(|p| p.extension().is_some_and(|x| x == "xtl")).collect())
            .unwrap_or_default();
        demos.sort();
        let _ = write!(
            out,
            "  Library {{ name: {name:?}, summary: {summary:?}, alias: {alias:?}, source: {src:?}, docs: {docs:?}, types: {types:?}, demos: &["
        );
        for d in demos {
            let stem = d.file_stem().unwrap().to_string_lossy().to_string();
            let text = fs::read_to_string(&d).unwrap();
            let expected = fs::read_to_string(dir.join(format!("tests/demo-{stem}.out"))).unwrap_or_default();
            let _ = write!(out, "Demo {{ name: {stem:?}, source: {text:?}, expected: {expected:?} }}, ");
        }
        out.push_str("] },\n");
    }
    out.push_str("];\n");
    let dest = PathBuf::from(std::env::var("OUT_DIR").unwrap()).join("catalog.rs");
    fs::write(dest, out).unwrap();
}

/// A library's page as HTML: links to its demos go to the demo in this
/// site; other relative links go to the file in the repository.
fn html(name: &str, md: &str) -> String {
    use pulldown_cmark::{CowStr, Event, Options, Parser, Tag};
    let parser = Parser::new_ext(md, Options::ENABLE_TABLES).map(|event| match event {
        Event::Start(Tag::Link { link_type, dest_url, title, id }) => {
            let url = dest_url.to_string();
            let url = if let Some(demo) = url.strip_prefix("../demos/").and_then(|d| d.strip_suffix(".xtl")) {
                format!("#{name}/{demo}")
            } else if url.contains("://") || url.starts_with('#') {
                url
            } else {
                format!("{REPO}/libs/{name}/docs/{url}")
            };
            Event::Start(Tag::Link { link_type, dest_url: CowStr::from(url), title, id })
        }
        e => e,
    });
    let mut html = String::new();
    pulldown_cmark::html::push_html(&mut html, parser);
    html
}
