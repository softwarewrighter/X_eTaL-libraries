//! The page: the libraries down the side; for the one chosen, its demos
//! (editable and runnable), its reference, its source and its types.
//! The address names what is shown: #Strings/word-count.

use std::cell::RefCell;
use std::rc::Rc;

use wasm_bindgen::closure::Closure;
use wasm_bindgen::JsCast;
use web_sys::HtmlTextAreaElement;
use yew::prelude::*;

use xetal_libraries_site::drawn::program;
use xetal_libraries_site::render::decorated;
use xetal_libraries_site::{default_demo, reference_demo, expansion, expansion_marked, library, Library, FEATURED_SCENES, GROUPS, LIBRARIES};

/// A program in its rendered form, as a block, its equations drawn as
/// math (drawn::program).
fn rendered(src: &str) -> Html {
    Html::from_html_unchecked(AttrValue::from(format!("<pre class=\"xtl\">{}</pre>", program(src))))
}

/// An export's type line (`l:g_cd : Int -> Int -> Int`): its name
/// rendered under the library's alias, its type as written.
fn type_line(alias: &str, line: &str) -> Html {
    let (name, ty) = line.split_once(" : ").unwrap_or((line, ""));
    let name = format!("{alias}{}", name.trim_start_matches("l:"));
    let html = format!("<span class=\"tname\">{}</span> <span class=\"ttype\">: {}</span>", decorated(&name), ty.replace('&', "&amp;").replace('<', "&lt;").replace('>', "&gt;"));
    Html::from_html_unchecked(AttrValue::from(format!("<div class=\"typeline\">{html}</div>")))
}

#[derive(Clone, Copy, PartialEq)]
enum Tab {
    Demos,
    Reference,
    Source,
    Types,
}

/// What the address names: a library and one of its demos.
fn from_hash() -> (&'static Library, usize) {
    let hash = web_sys::window().and_then(|w| w.location().hash().ok()).unwrap_or_default();
    let hash = hash.trim_start_matches('#');
    let (name, demo) = hash.split_once('/').unwrap_or((hash, ""));
    let lib = library(name).unwrap_or(&LIBRARIES[0]);
    let i = lib.demos.iter().position(|d| d.name == demo).unwrap_or_else(|| default_demo(lib));
    (lib, i)
}

/// The address, without the #.
fn hash_now() -> String {
    let hash = web_sys::window().and_then(|w| w.location().hash().ok()).unwrap_or_default();
    hash.trim_start_matches('#').to_string()
}

/// The address of a library and demo, without the #.
fn hash_of(lib: &Library, demo: usize) -> String {
    let tail = lib.demos.get(demo).map(|d| format!("/{}", d.name)).unwrap_or_default();
    format!("{}{}", lib.name, tail)
}

fn set_hash(hash: &str) {
    if let Some(w) = web_sys::window() {
        let _ = w.location().set_hash(hash);
    }
}

#[derive(Clone, Default, PartialEq)]
struct Output {
    out: String,
    err: String,
    pictures: Vec<String>,
    ran: bool,
    elapsed_ms: Option<f64>,
}

#[function_component(App)]
pub fn app() -> Html {
    let start = from_hash();
    let lib = use_state(|| start.0);
    let demo = use_state(|| start.1);
    let tab = use_state(|| Tab::Demos);
    let text = use_state(|| start.0.demos.get(start.1).map(|d| d.source.to_string()).unwrap_or_default());
    let output = use_state(Output::default);
    let seed = use_state(|| 1u64);
    let editing = use_state(|| false);
    let expanded = use_state(|| false);
    let library_menu = use_state(|| false);
    // The landing page: shown when the address names no library.
    let home = use_state(|| library(hash_now().split('/').next().unwrap_or("")).is_none());
    // Source decoration and macro inspection load libraries. Output-only updates
    // must not repeat that work after every Run.
    let source_view = use_memo((*text).clone(), |src| rendered(src));
    let can_expand = use_memo((*text).clone(), |src| expansion(src).is_some());
    let expanded_source = use_memo(((*text).clone(), *expanded), |(src, show)| {
        if *show { expansion_marked(src) } else { None }
    });
    let import_view = use_memo((lib.name, lib.alias), |(name, alias)| {
        rendered(&format!("{alias:?} u_se< {name:?}"))
    });
    let intro_view = use_memo((), |_| rendered("\"t:\" u_se< \"Strings\"\nt:u_pper \"hello\"            # HELLO"));

    // The address last shown, so a change made here is not shown twice.
    let shown: Rc<RefCell<String>> = use_mut_ref(|| hash_of(start.0, start.1));
    let choose = {
        let (lib, demo, text, output, shown, home, library_menu, editing, expanded) = (lib.clone(), demo.clone(), text.clone(), output.clone(), shown.clone(), home.clone(), library_menu.clone(), editing.clone(), expanded.clone());
        move |l: &'static Library, i: usize| {
            home.set(false);
            library_menu.set(false);
            editing.set(false);
            expanded.set(false);
            let hash = hash_of(l, i);
            *shown.borrow_mut() = hash.clone();
            set_hash(&hash);
            lib.set(l);
            demo.set(i);
            text.set(l.demos.get(i).map(|d| d.source.to_string()).unwrap_or_default());
            output.set(Output::default());
            if let Some(window) = web_sys::window() {
                window.scroll_to_with_x_and_y(0.0, 0.0);
            }
        }
    };

    // Back, forward and links to #Library/demo show what they name.
    {
        let (choose, shown, tab, home) = (choose.clone(), shown.clone(), tab.clone(), home.clone());
        use_effect_with((), move |_| {
            let on_change = Closure::<dyn Fn()>::new(move || {
                if library(hash_now().split('/').next().unwrap_or("")).is_none() {
                    *shown.borrow_mut() = String::new();
                    home.set(true);
                    return;
                }
                let (l, i) = from_hash();
                if hash_of(l, i) != *shown.borrow() {
                    choose(l, i);
                    tab.set(Tab::Demos);
                }
            });
            let window = web_sys::window();
            if let Some(w) = &window {
                let _ = w.add_event_listener_with_callback("hashchange", on_change.as_ref().unchecked_ref());
            }
            move || {
                if let Some(w) = window {
                    let _ = w.remove_event_listener_with_callback("hashchange", on_change.as_ref().unchecked_ref());
                }
            }
        });
    }

    let run = {
        let (text, output, seed) = (text.clone(), output.clone(), seed.clone());
        Callback::from(move |_| {
            let clock = web_sys::window().and_then(|w| w.performance());
            let start = clock.as_ref().map(|c| c.now());
            let r = xetal_play::run(&text, *seed);
            let elapsed_ms = start.zip(clock.as_ref()).map(|(start, clock)| clock.now() - start);
            output.set(Output { out: r.out, err: r.err, pictures: r.pictures, ran: true, elapsed_ms });
        })
    };
    let reroll = {
        let seed = seed.clone();
        Callback::from(move |_| seed.set(*seed % 1_000_003 * 7919 + 17))
    };
    let toggle_edit = {
        let editing = editing.clone();
        Callback::from(move |_| editing.set(!*editing))
    };
    let toggle_expand = {
        let expanded = expanded.clone();
        Callback::from(move |_| expanded.set(!*expanded))
    };
    let reset = {
        let (lib, demo, text, output, editing, expanded) = (lib.clone(), demo.clone(), text.clone(), output.clone(), editing.clone(), expanded.clone());
        Callback::from(move |_| {
            text.set(lib.demos.get(*demo).map(|d| d.source.to_string()).unwrap_or_default());
            output.set(Output::default());
            editing.set(false);
            expanded.set(false);
            if let Some(window) = web_sys::window() {
                window.scroll_to_with_x_and_y(0.0, 0.0);
            }
        })
    };
    let edit = {
        let (text, output) = (text.clone(), output.clone());
        Callback::from(move |e: InputEvent| {
            let area: HtmlTextAreaElement = e.target_unchecked_into();
            text.set(area.value());
            output.set(Output::default());
        })
    };

    let nav = LIBRARIES.iter().map(|l| {
        let choose = choose.clone();
        let tab = tab.clone();
        let current = !*home && l.name == lib.name;
        let onclick = Callback::from(move |_| {
            choose(l, default_demo(l));
            tab.set(Tab::Demos);
        });
        html! {
            <li class={classes!(current.then_some("current"))} {onclick}>
                <span class="name">{ l.name }</span>
                <code class="alias">{ l.alias }</code>
                <span class="summary">{ l.summary }</span>
            </li>
        }
    });

    let tabs = [(Tab::Demos, "Demos"), (Tab::Reference, "Reference"), (Tab::Source, "Source"), (Tab::Types, "Types")]
        .into_iter()
        .map(|(t, label)| {
            let tab = tab.clone();
            let current = *tab == t;
            html! { <button class={classes!("tab", current.then_some("current"))} onclick={Callback::from(move |_| tab.set(t))}>{ label }</button> }
        });

    let start_here = {
        let (home, shown, library_menu) = (home.clone(), shown.clone(), library_menu.clone());
        Callback::from(move |_| {
            *shown.borrow_mut() = String::new();
            set_hash("");
            home.set(true);
            library_menu.set(false);
            if let Some(window) = web_sys::window() {
                window.scroll_to_with_x_and_y(0.0, 0.0);
            }
        })
    };
    let toggle_library_menu = {
        let library_menu = library_menu.clone();
        Callback::from(move |_| library_menu.set(!*library_menu))
    };

    // The landing page: what this is, how to use a library, how it fits,
    // and the libraries in groups.
    let landing = {
        let groups = GROUPS.iter().map(|(group, names)| {
            let cards = names.iter().filter_map(|n| library(n)).map(|l| {
                let choose = choose.clone();
                let tab = tab.clone();
                let onclick = Callback::from(move |_| {
                    choose(l, default_demo(l));
                    tab.set(Tab::Demos);
                });
                html! {
                    <button class="card" {onclick}>
                        <span class="name">{ l.name }<code class="alias">{ l.alias }</code></span>
                        <span class="summary">{ l.summary }</span>
                    </button>
                }
            });
            html! { <><h3>{ *group }</h3><div class="cards">{ for cards }</div></> }
        });
        let scenes = FEATURED_SCENES.iter().filter_map(|(name, demo, title, description)| {
            let d = library(name)?.demos.iter().find(|d| d.name == *demo)?;
            let image = d.presentation_image()?;
            Some(html! {
                <a class="scene-card" href={format!("#{name}/{demo}")}>
                    <div class="scene-image"><img src={image} alt={title.to_string()} /></div>
                    <div class="scene-caption"><strong>{ *title }</strong><span>{ *description }</span></div>
                </a>
            })
        });
        html! {
            <div class="landing">
                <h2>{ "Libraries in action" }</h2>
                <p class="lead">{ "Scenes rendered in X_eTaL. Open an image to explore its program." }</p>
                <div class="scene-gallery">{ for scenes }</div>
                <h3>{ "Explore the libraries" }</h3>
                <p>{ format!("{} libraries written in X_eTaL itself, from text and dates to matrices, statistics and graphs. Pick one below to run and edit its demos.", LIBRARIES.len()) }</p>
                <p>{ "In a program of your own, one line imports a library under an alias of your choice, and its functions then read like the built-ins:" }</p>
                { (*intro_view).clone() }
                <p>{ "X_eTaL extends in three ways:" }</p>
                <table class="layers">
                    <tr><th>{ "Extends" }</th><th>{ "With" }</th><th>{ "Where" }</th></tr>
                    <tr><td>{ "the vocabulary" }</td><td>{ ".xtl libraries: functions written in X_eTaL" }</td><td><b>{ "here" }</b></td></tr>
                    <tr><td>{ "the language" }</td><td>{ ".xtlm macro libraries: source in, source out, before the program runs" }</td><td>{ "here too: macros beside Dates, Polynomials and Graphs" }</td></tr>
                    <tr><td>{ "the machine" }</td><td>{ "native code behind typed X_eTaL facades" }</td><td><a href="https://github.com/softwarewrighter/X_eTaL-extensions">{ "X_eTaL-extensions" }</a></td></tr>
                </table>
                { for groups }
                <p class="more">{ "Every library's full source, cross-linked and searchable, with its demos: " }
                    <a href="doc/index.html" target="_blank">{ "the cross-reference (xetal doc)" }</a>{ "." }
                </p>
                <p class="more">{ "More of X_eTaL: " }
                    <a href="https://softwarewrighter.github.io/X_eTaL/">{ "the language's live demo" }</a>{ ", " }
                    <a href="https://softwarewrighter.github.io/X_eTaL-demos/">{ "visual demos" }</a>{ ", " }
                    <a href="https://github.com/softwarewrighter/X_eTaL-ML">{ "machine learning" }</a>{ ", " }
                    <a href="https://softwarewrighter.github.io/X_eTaL-games/">{ "games" }</a>{ "." }
                </p>
            </div>
        }
    };

    let l: &'static Library = *lib;
    let reference = reference_demo(l, *demo);
    let diagnostic = l.name == "Glass" && l.demos.get(*demo).is_some_and(|d| d.name == "cap-convergence");
    let body = match *tab {
        Tab::Demos => {
            let chips = l.demos.iter().enumerate().map(|(i, d)| {
                let choose = choose.clone();
                let current = i == *demo;
                html! { <button class={classes!("chip", current.then_some("current"))} onclick={Callback::from(move |_| choose(l, i))}>{ format!("{}.xtl", d.name) }</button> }
            });
            let pictures = output.pictures.iter().map(|svg| Html::from_html_unchecked(AttrValue::from(svg.clone())));
            let source = if *editing {
                html! { <div class="edit">
                    <div class="pane"><div class="label">{ "ASCII (as typed)" }</div>
                        <textarea class="editor" spellcheck="false" value={(*text).clone()} oninput={edit}
                            rows={(text.lines().count() + 1).max(8).to_string()} />
                    </div>
                    <div class="pane"><div class="label">{ "Rendered" }</div>{ (*source_view).clone() }</div>
                </div> }
            } else { (*source_view).clone() };
            html! {
                <div class="demos">
                    <div class="chips">{ for chips }</div>
                    if let Some(scene) = reference {
                        <div class="reference-preview pictures">
                            <div class="preview-label">{ "Reference render" }
                                if l.demos.get(*demo).is_some_and(|d| d.name != scene.name) {
                                    { " from " }<a href={format!("#{}/{}", l.name, scene.name)}>{ format!("{}.xtl", scene.name) }</a>
                                }
                            </div>
                            { Html::from_html_unchecked(AttrValue::from(scene.presentation.unwrap())) }
                        </div>
                        <details class="program-source" open={*editing}>
                            <summary>{ "Explore the program" }</summary>
                            { (*import_view).clone() }
                            { source }
                        </details>
                    } else {
                        { source }
                    }
                    <div class="actions">
                        <button class="run" onclick={run}>{
                            if diagnostic { "Run diagnostic" }
                            else if reference.is_some() { "Run small test" } else { "Run" }
                        }</button>
                        <button onclick={toggle_edit}>{ if *editing { "Done editing" } else { "Edit" } }</button>
                        <button onclick={reset}>{ "Reset" }</button>
                        <button onclick={toggle_expand} disabled={!*can_expand}
                            title="the program after its macros are expanded (xetal expand)">
                            { if *expanded { "Hide expansion" } else { "Expand" } }</button>
                        <button onclick={reroll} title="a new seed for r_oll!">{ format!("Seed {}", *seed) }</button>
                        if let Some(ms) = output.elapsed_ms {
                            <span class="run-timing" role="status">{ format!("Run time: {:.2} s", ms / 1000.0) }</span>
                        }
                        if diagnostic {
                            <span class="hint">{ "Runs the full cap-convergence diagnostic and may take longer." }</span>
                        } else if reference.is_some() {
                            <span class="hint">{ "Runs a small live test; the antialiased reference stays above. Increase size in the program for a slower, larger render." }</span>
                        } else {
                            <span class="hint">{ "Edit types the program in ASCII beside its rendered form; every library here can be imported with " }{ Html::from_html_unchecked(AttrValue::from(format!("<code class=\"xtl\">{}</code>", decorated("u_se<")))) }{ "." }</span>
                        }
                    </div>
                    if output.ran && !output.pictures.is_empty() {
                        if reference.is_some() {
                            <details class="quick-output">
                                <summary>{ if diagnostic { "Show the diagnostic render (low resolution)" } else { "Show the small test render (low resolution)" } }</summary>
                                <div class="pictures">{ for pictures }</div>
                            </details>
                        } else {
                            <div class="pictures">{ for pictures }</div>
                        }
                    }
                    if *expanded {
                        { match expanded_source.as_ref() {
                            Some(Ok(lines)) => {
                                let body: String = lines.iter().map(|(l, changed)| {
                                    let l = decorated(l);
                                    if *changed { format!("<span class=\"changed\">{l}</span>\n") } else { format!("{l}\n") }
                                }).collect();
                                html! { <div class="expansion">
                                    <div class="label">{ "Expanded, as xetal expand prints it: the highlighted lines are what the macro calls became" }</div>
                                    { Html::from_html_unchecked(AttrValue::from(format!("<pre class=\"xtl\">{body}</pre>"))) }
                                </div> }
                            }
                            Some(Err(e)) => html! { <pre class="err">{ e.clone() }</pre> },
                            None => html! {},
                        } }
                    }
                    if output.ran {
                        { output_html(&output.out) }
                        if !output.err.is_empty() { <pre class="err">{ &output.err }</pre> }
                    }
                </div>
            }
        }
        Tab::Reference => html! { <div class="docs">{ Html::from_html_unchecked(AttrValue::from(l.docs)) }</div> },
        Tab::Source => rendered(l.source),
        Tab::Types => html! { <div class="types">{ for l.types.lines().map(|t| type_line(l.alias, t)) }</div> },
    };

    html! {
        <>
        <header>
            <img src="xetal-logo.png" alt="X_eTaL" />
            <div>
                <h1>{ "X_eTaL libraries" }</h1>
                <p>{ "Libraries written in X_eTaL, the eXperimental Extensible Typed Array Language: run their demos, edit them, read their references." }</p>
            </div>
        </header>
        <main>
            <nav aria-label="Libraries">
                <button class="library-toggle" onclick={toggle_library_menu} aria-controls="library-list" aria-expanded={library_menu.to_string()}>{ "Browse libraries" }</button>
                <ul id="library-list" class={classes!("library-list", (*library_menu).then_some("open"))}>
                <li class={classes!("start", home.then_some("current"))} onclick={start_here}><span class="name">{ "Start here" }</span></li>
                { for nav }
            </ul></nav>
            if *home {
                <section>{ landing }</section>
            } else {
            <section>
                <h2>{ l.name }<code class="alias">{ l.alias }</code></h2>
                <p class="summary">{ l.summary }</p>
                if *tab != Tab::Demos || reference.is_none() {
                    <div class="import">{ (*import_view).clone() }</div>
                }
                <div class="tabs">{ for tabs }</div>
                { body }
            </section>
            }
        </main>
        <footer>
            <a href="https://github.com/softwarewrighter/X_eTaL-libraries">{ "Source on GitHub" }</a>
            { " | " }
            <a href="doc/index.html" target="_blank">{ "Cross-reference (xetal doc)" }</a>
            { " | " }
            <a href="https://github.com/softwarewrighter/X_eTaL">{ "X_eTaL" }</a>
            { " | MIT License, Copyright (c) 2026 Michael A Wright" }
        </footer>
        </>
    }
}

/// A program's output: text, with each `$$ ... $$` line drawn as math
/// (the LaTeX itself on hover).
fn output_html(out: &str) -> Html {
    let lines = xetal_libraries_site::math::lines(out).into_iter().map(|line| match line {
        xetal_libraries_site::math::Line::Text(text) => html! { <>{ text }{ "\n" }</> },
        xetal_libraries_site::math::Line::Math(tex) => {
            let span = format!(
                "<span class=\"math\" title=\"{}\">{}</span>\n",
                xetal_libraries_site::math::escaped(tex),
                xetal_libraries_site::math::html(tex)
            );
            Html::from_html_unchecked(AttrValue::from(span))
        }
    });
    html! { <pre class="out">{ for lines }</pre> }
}
