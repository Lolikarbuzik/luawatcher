use super::parsers::{local_functions, local_variables};
use regex::Regex;
use std::{fs, io, time::Instant};

use crate::datatypes::{Args, LuaScope};

const RUNTIME_START_PAYLOAD: &str =
    "-- LuaWatcher build file\nlocal ____LW_RT = require(\"{}\")\nlocal ____LUAWATCHER = ____LW_RT.new()\n";
const RUNTIME_END_PAYLOAD: &str = "\n____LUAWATCHER:print_history()";

pub fn build(path: &str, args: &Args) -> io::Result<String> {
    let instant = Instant::now();
    let file_name = path.replacen("\\", "/", 20);
    let file_name = file_name.split("/").last().unwrap();
    let write_path = String::from("build/") + file_name;

    let mut contents = fs::read_to_string(path)?;
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
    fs::write(&write_path, contents)?;
    Ok(write_path)
}
