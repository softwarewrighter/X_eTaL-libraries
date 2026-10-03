//! The browser app: run with trunk (just serve, just pages).

mod app;

fn main() {
    console_error_panic_hook::set_once();
    xetal_libraries_site::store::install();
    yew::Renderer::<app::App>::new().render();
}
