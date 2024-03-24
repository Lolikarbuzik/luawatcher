use std::collections::HashMap;

use clap::{Parser, Subcommand};

/// Simple to use lua file watcher supporting multiple platforms
#[derive(Parser, Debug, Clone)]
pub struct Args {
    /// Command to run
    #[command(subcommand)]
    pub command: RunType,

    /// Path to the lua file to run
    /// Also when this value is set compiler will treat PATH as a directory
    /// and will look for all lua files in it
    #[arg(long, short)]
    pub entry: Option<String>,

    /// Watch mode
    #[arg(default_value_t = 0, long, short)]
    pub watch_mode: usize,

    /// Path to the LuaWatcher runtime file
    #[arg(default_value_t = String::from("runtime/luawatcher.lua"))]
    pub runtime_path: String,

    /// Path to the lua file/directory
    /// To compile every file in a dir set entry to empty string or path
    #[arg(short, long)]
    pub path: String,
}

#[derive(Subcommand, Debug, Clone)]
pub enum RunType {
    Run,
    Build,
}

pub enum LuaValue {
    Value,
    Function(LuaScope),
    Scope(LuaScope),
}

pub struct LuaScope {
    pub map: HashMap<String, LuaValue>,
    pub id: String,
}

impl LuaScope {
    pub fn new() -> Self {
        // TODO add probably global variables
        Self {
            map: HashMap::new(),
            id: String::from("GLOBAL_LUA_SCOPE"),
        }
    }

    pub fn push_str(&mut self, name: &str, mut value: LuaValue) {
        match &mut value {
            LuaValue::Function(scope) | LuaValue::Scope(scope) => scope.id = name.to_owned(),
            _ => {}
        };
        self.map.insert(name.to_owned(), value);
    }

    pub fn contains(&self, name: &str) -> bool {
        self.map.contains_key(name)
    }
}
