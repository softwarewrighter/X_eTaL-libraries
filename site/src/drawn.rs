//! A program rendered with its notations drawn (X_eTaL MC32, ask
//! X21): the app's view of a program; the reference pages, rendered at
//! build time, use `render` alone.

use xetal_view::{html, Class};

/// A program rendered, its notation calls drawn (X_eTaL MC32): the
/// program is loaded from the libraries' store, and each call whose
/// macro declares a notation side (Equations' `e:e_q<`) shows its two
/// strings as one math box, typeset by KaTeX, after the macro's name;
/// a program that does not load is drawn as typed.
pub fn program(src: &str) -> String {
    xetal_play::decorated(src)
        .iter()
        .map(|s| match s.class {
            Class::Notation => format!("<span class=\"c-notation\">{}</span>", xetal_katex::html(&s.text)),
            _ => html(std::slice::from_ref(s)),
        })
        .collect()
}
