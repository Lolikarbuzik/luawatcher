use super::parsers::{local_functions, local_variables};
use regex::Regex;
use std::{fs, io, time::Instant};

use crate::{
    datatypes::{Args, LuaScope},
    util::write_path,
};

const RUNTIME_START_PAYLOAD: &str =
    "-- LuaWatcher build file\nlocal ____LW_RT = require(\"{}\")\nlocal ____LUAWATCHER = ____LW_RT.new()\n";
const RUNTIME_END_PAYLOAD: &str = "\n____LUAWATCHER:print_history()";

pub fn build(path: &str, args: &Args) -> io::Result<String> {
    // TODO try to ignore first dir in the path?
    // test/functions.lua -> build/functions.lua
    // test/scopes/scopes.lua -> build/scopes/scopes.lua
    if !fs::metadata("build/").is_ok() {
        fs::create_dir("build/").unwrap();
    }
    let instant = Instant::now();
    let path = path.replacen("\\", "/", 20);
    let split = path.split("/").collect::<Vec<&str>>();
    let file_name = split.last().unwrap();

    let mut contents = fs::read_to_string(&path)?;
    if path.ends_with(".lua") {
        contents = Regex::new("--.*")
            .unwrap()
            .replace_all(&contents, "")
            .to_string();
        println!("Building {file_name}");

        let mut scope = LuaScope::new();

        // TODO
        match args.watch_mode {
            0 => {}
            1 => {
                local_variables(&mut contents, &mut scope);
                local_functions(&mut contents, &mut scope);
            }
            2 => {}
            _ => {}
        }

        // Inserting payloads
        contents.insert_str(
            0,
            RUNTIME_START_PAYLOAD
                .replace("{}", args.runtime_path.clone().replace(".lua", "").as_str())
                .as_str(),
        );
        contents.push_str(RUNTIME_END_PAYLOAD);
        // TODO revise this to work for `return <fn>` since you cant add code below a return

        println!(
            "Finished building {file_name} in {}ms",
            instant.elapsed().as_millis()
        );
    }
    write_path(&path, contents)
}
