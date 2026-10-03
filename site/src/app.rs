//! The page: the libraries down the side; for the one chosen, its demos
//! (editable and runnable), its reference, its source and its types.
//! The address names what is shown: #Strings/word-count.

use std::cell::RefCell;
use std::rc::Rc;

use wasm_bindgen::closure::Closure;
use wasm_bindgen::JsCast;
use web_sys::HtmlTextAreaElement;
use yew::prelude::*;

use xetal_libraries_site::{library, Library, LIBRARIES};

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
    let i = lib.demos.iter().position(|d| d.name == demo).unwrap_or(0);
    (lib, i)
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

    // The address last shown, so a change made here is not shown twice.
    let shown: Rc<RefCell<String>> = use_mut_ref(|| hash_of(start.0, start.1));
    let choose = {
        let (lib, demo, text, output, shown) = (lib.clone(), demo.clone(), text.clone(), output.clone(), shown.clone());
        move |l: &'static Library, i: usize| {
            let hash = hash_of(l, i);
            *shown.borrow_mut() = hash.clone();
            set_hash(&hash);
            lib.set(l);
            demo.set(i);
            text.set(l.demos.get(i).map(|d| d.source.to_string()).unwrap_or_default());
            output.set(Output::default());
        }
    };

    // Back, forward and links to #Library/demo show what they name.
    {
        let (choose, shown, tab) = (choose.clone(), shown.clone(), tab.clone());
        use_effect_with((), move |_| {
            let on_change = Closure::<dyn Fn()>::new(move || {
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
            let r = xetal_play::run(&text, *seed);
            output.set(Output { out: r.out, err: r.err, pictures: r.pictures, ran: true });
        })
    };
    let reroll = {
        let seed = seed.clone();
        Callback::from(move |_| seed.set(*seed % 1_000_003 * 7919 + 17))
    };
    let reset = {
        let (lib, demo, text, output) = (lib.clone(), demo.clone(), text.clone(), output.clone());
        Callback::from(move |_| {
            text.set(lib.demos.get(*demo).map(|d| d.source.to_string()).unwrap_or_default());
            output.set(Output::default());
        })
    };
    let edit = {
        let text = text.clone();
        Callback::from(move |e: InputEvent| {
            let area: HtmlTextAreaElement = e.target_unchecked_into();
            text.set(area.value());
        })
    };

    let nav = LIBRARIES.iter().map(|l| {
        let choose = choose.clone();
        let tab = tab.clone();
        let current = l.name == lib.name;
        let onclick = Callback::from(move |_| {
            choose(l, 0);
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

    let l: &'static Library = *lib;
    let body = match *tab {
        Tab::Demos => {
            let chips = l.demos.iter().enumerate().map(|(i, d)| {
                let choose = choose.clone();
                let current = i == *demo;
                html! { <button class={classes!("chip", current.then_some("current"))} onclick={Callback::from(move |_| choose(l, i))}>{ format!("{}.xtl", d.name) }</button> }
            });
            let pictures = output.pictures.iter().map(|svg| Html::from_html_unchecked(AttrValue::from(svg.clone())));
            html! {
                <div class="demos">
                    <div class="chips">{ for chips }</div>
                    <textarea class="editor" spellcheck="false" value={(*text).clone()} oninput={edit}
                        rows={(text.lines().count() + 1).max(8).to_string()} />
                    <div class="actions">
                        <button class="run" onclick={run}>{ "Run" }</button>
                        <button onclick={reset}>{ "Reset" }</button>
                        <button onclick={reroll} title="a new seed for r_oll!">{ format!("Seed {}", *seed) }</button>
                        <span class="hint">{ "Edit the program and run it: every library here is available to u_se<." }</span>
                    </div>
                    if output.ran {
                        <pre class="out">{ &output.out }</pre>
                        if !output.err.is_empty() { <pre class="err">{ &output.err }</pre> }
                        <div class="pictures">{ for pictures }</div>
                    }
                </div>
            }
        }
        Tab::Reference => html! { <div class="docs">{ Html::from_html_unchecked(AttrValue::from(l.docs)) }</div> },
        Tab::Source => html! { <pre class="source">{ l.source }</pre> },
        Tab::Types => html! { <pre class="source">{ l.types }</pre> },
    };

    html! {
        <>
        <header>
            <img src="xetal-logo.jpg" alt="X_eTaL" />
            <div>
                <h1>{ "X_eTaL libraries" }</h1>
                <p>{ "Libraries written in X_eTaL, the eXperimental Extensible Typed Array Language: run their demos, edit them, read their references." }</p>
            </div>
        </header>
        <main>
            <nav><ul>{ for nav }</ul></nav>
            <section>
                <h2>{ l.name }<code class="alias">{ l.alias }</code></h2>
                <p class="summary">{ l.summary }</p>
                <pre class="import">{ format!("{:?} u_se< {:?}", l.alias, l.name) }</pre>
                <div class="tabs">{ for tabs }</div>
                { body }
            </section>
        </main>
        <footer>
            <a href="https://github.com/softwarewrighter/X_eTaL-libraries">{ "Source on GitHub" }</a>
            { " | " }
            <a href="https://github.com/softwarewrighter/X_eTaL">{ "X_eTaL" }</a>
            { " | MIT License, Copyright (c) 2026 Michael A Wright" }
        </footer>
        </>
    }
}
