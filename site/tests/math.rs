//! Output lines between `$$` are math; the rest is text.

use xetal_libraries_site::math::{escaped, lines, Line};

#[test]
fn a_line_between_double_dollars_is_math() {
    let out = "560 596 632\n$$Y_{o,h,w} = \\sum_{c=0}^{C - 1} X_{c}$$\n1\n";
    assert_eq!(
        lines(out),
        [
            Line::Text("560 596 632"),
            Line::Math("Y_{o,h,w} = \\sum_{c=0}^{C - 1} X_{c}"),
            Line::Text("1"),
        ]
    );
}

#[test]
fn dollars_alone_or_unclosed_stay_text() {
    assert_eq!(lines("$$"), [Line::Text("$$")]);
    assert_eq!(lines("$$$"), [Line::Text("$$$")]);
    assert_eq!(lines("$$ x"), [Line::Text("$$ x")]);
    assert_eq!(lines("  $$ x $$  "), [Line::Math("x")]);
}

#[test]
fn latex_is_escaped_for_an_attribute() {
    assert_eq!(escaped("a < b & \"c\""), "a &lt; b &amp; &quot;c&quot;");
}
