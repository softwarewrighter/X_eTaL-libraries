//! The store a program runs against: every library as `Name.xtl`, files
//! the program writes kept in memory, pictures it shows collected.

use std::collections::HashMap;
use std::sync::{Arc, Mutex};

use xetal_store::Store;

use crate::LIBRARIES;

#[derive(Default)]
pub struct Memory {
    files: Mutex<HashMap<String, String>>,
    shown: Mutex<Vec<String>>,
}

impl Memory {
    /// A store holding every library.
    pub fn with_libraries() -> Self {
        let files = LIBRARIES.iter().map(|l| (format!("{}.xtl", l.name), l.source.to_string())).collect();
        Memory { files: Mutex::new(files), ..Memory::default() }
    }
}

impl Store for Memory {
    fn get(&self, path: &str) -> Result<String, String> {
        let files = self.files.lock().map_err(|e| e.to_string())?;
        files.get(path).cloned().ok_or_else(|| format!("{path}: no such file"))
    }

    fn put(&self, path: &str, text: &str) -> Result<(), String> {
        let mut files = self.files.lock().map_err(|e| e.to_string())?;
        files.insert(path.to_string(), text.to_string());
        Ok(())
    }

    fn line(&self) -> Result<String, String> {
        Err("the live demo has no keyboard input".into())
    }

    fn show(&self, svg: &str) -> Result<(), String> {
        self.shown.lock().map_err(|e| e.to_string())?.push(svg.to_string());
        Ok(())
    }

    fn take_shown(&self) -> Vec<String> {
        self.shown.lock().map(|mut s| std::mem::take(&mut *s)).unwrap_or_default()
    }
}

/// Install the libraries' store for every run from now on.
pub fn install() {
    xetal_store::install(Arc::new(Memory::with_libraries()));
}
