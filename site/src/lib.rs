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

/// The library named `name`.
pub fn library(name: &str) -> Option<&'static Library> {
    LIBRARIES.iter().find(|l| l.name == name)
}
