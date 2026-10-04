//! The live demo of X_eTaL-libraries: the libraries embedded at build
//! time (build.rs), served to xetal-play from a store in memory, so a
//! program's `u_se<` finds them in the browser.

pub mod render;
pub mod store;

/// A library as the site shows it.
pub struct Library {
    pub name: &'static str,
    pub summary: &'static str,
    pub alias: &'static str,
    pub source: &'static str,
    /// Its reference page, rendered to HTML.
    pub docs: &'static str,
    /// `xetal type` of it, as its tests pin.
    pub types: &'static str,
    pub demos: &'static [Demo],
}

/// A demo program and its recorded output (tests/demo-NAME.out).
pub struct Demo {
    pub name: &'static str,
    pub source: &'static str,
    pub expected: &'static str,
}

include!(concat!(env!("OUT_DIR"), "/catalog.rs"));

/// The libraries in groups, as the landing page and the README show
/// them (a test requires every library to be in exactly one).
pub const GROUPS: &[(&str, &[&str])] = &[
    ("Foundations", &["Check", "Strings", "Lists", "Sets"]),
    ("Data", &["Csv", "Grouping", "Search", "Statistics", "Dates"]),
    ("Mathematics", &["Numbers", "Combinatorics", "Matrix", "Polynomials", "Geometry", "Graphs", "Bits", "Random"]),
    ("Output", &["Format", "Plot"]),
];

/// A program after macro expansion, when it holds a macro call other
/// than `u_se<` (X_eTaL's system macros, `xetal expand`): `None` when
/// nothing would change, the expansion's error as text when it fails.
pub fn expansion(src: &str) -> Option<Result<String, String>> {
    match xetal_expand::expand(src) {
        Ok(m) if m.text() == src => None,
        Ok(m) => Some(Ok(m.text().to_string())),
        Err(d) => Some(Err(d.to_string())),
    }
}

/// The lines of a program's expansion, each marked when it is not a
/// line of the program as written (what a macro call became), by the
/// longest common run of lines; `None` when nothing would change.
pub fn expansion_marked(src: &str) -> Option<Result<Vec<(String, bool)>, String>> {
    let e = match expansion(src)? {
        Ok(e) => e,
        Err(d) => return Some(Err(d)),
    };
    let a: Vec<&str> = src.trim_end().lines().collect();
    let b: Vec<&str> = e.trim_end().lines().collect();
    // lcs[i][j]: the longest common run of a[i..] and b[j..].
    let mut lcs = vec![vec![0usize; b.len() + 1]; a.len() + 1];
    for i in (0..a.len()).rev() {
        for j in (0..b.len()).rev() {
            lcs[i][j] = if a[i] == b[j] { lcs[i + 1][j + 1] + 1 } else { lcs[i + 1][j].max(lcs[i][j + 1]) };
        }
    }
    let (mut i, mut j, mut out) = (0, 0, Vec::new());
    while j < b.len() {
        if i < a.len() && a[i] == b[j] {
            out.push((b[j].to_string(), false));
            i += 1;
            j += 1;
        } else if i < a.len() && lcs[i + 1][j] >= lcs[i][j + 1] {
            i += 1;
        } else {
            out.push((b[j].to_string(), true));
            j += 1;
        }
    }
    Some(Ok(out))
}

/// The library named `name`.
pub fn library(name: &str) -> Option<&'static Library> {
    LIBRARIES.iter().find(|l| l.name == name)
}
