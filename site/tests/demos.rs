//! Every demo, run through xetal-play with the libraries' store (as the
//! browser runs it, seed 1, ASCII frames), prints what its reg-rs
//! baseline recorded; every library's types are what the page shows.

use xetal_libraries_site::{store, LIBRARIES};

#[test]
fn every_demo_runs_as_recorded() {
    store::install();
    xetal_grid::set_ascii(true);
    let mut n = 0;
    for lib in LIBRARIES {
        assert!(!lib.demos.is_empty(), "{} has no demo", lib.name);
        for demo in lib.demos {
            let run = xetal_play::run(demo.source, 1);
            assert_eq!(run.err, "", "{}/{}: error", lib.name, demo.name);
            // The command line reports each picture it writes ("drawn ..."); the browser shows it instead.
            let expected: String = demo.expected.lines().filter(|l| !l.starts_with("drawn ")).map(|l| format!("{l}\n")).collect();
            assert_eq!(run.out, expected, "{}/{}: output", lib.name, demo.name);
            n += 1;
        }
    }
    assert!(n >= LIBRARIES.len());
}

#[test]
fn every_library_checks_to_its_pinned_types() {
    store::install();
    for lib in LIBRARIES {
        let lines = xetal_play::check(lib.source);
        assert_eq!(lines.join("\n") + "\n", lib.types, "{} types", lib.name);
    }
}

#[test]
fn the_catalog_has_every_library() {
    assert!(LIBRARIES.len() >= 8);
    for lib in LIBRARIES {
        assert!(!lib.alias.is_empty() && lib.alias.ends_with(':'), "{} alias", lib.name);
        assert!(lib.docs.contains("<table>"), "{} docs", lib.name);
    }
}

#[test]
fn pages_show_xetal_rendered_not_typed() {
    // Typed spellings that the rendered form always decorates.
    for lib in LIBRARIES {
        for typed in ["u_se&lt;", "r_/", " := ", "s_elect", "t_ally"] {
            assert!(!lib.docs.contains(typed), "{}: typed {typed:?} on its reference page", lib.name);
        }
        assert!(lib.docs.contains("class=\"c-"), "{}: nothing rendered", lib.name);
    }
}
