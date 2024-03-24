mod build;
mod datatypes;
mod error;
mod parsers;

use build::build;
use clap::Parser;
use datatypes::RunType;
use error::perror;
use std::{
    fs, io,
    process::Command,
    time::{self, Instant},
};

use crate::datatypes::Args;

// Returns String or empty string
pub fn build_from_path(path: &str, args: &Args) -> io::Result<String> {
    if let Ok(metadata) = std::fs::metadata(path) {
        if metadata.is_dir() {
            if let Ok(paths) = fs::read_dir(path) {
                for fpath in paths {
                    let fpath = fpath.unwrap();
                    build_from_path(fpath.path().to_str().unwrap(), args)?;
                }
            }
        } else {
            return build(path, &Args::parse());
        }
    }
    Ok(String::new())
}

fn main() -> io::Result<()> {
    let args = Args::parse();
    match args.command {
        RunType::Build => {
            let instant = Instant::now();
            build_from_path(&args.path, &args).unwrap();
            println!(
                "Finished building \"{}\" in {}ms",
                &args.path,
                instant.elapsed().as_millis()
            );
        }
        RunType::Run => {
            let write_path = build(&args.path, &args)?;
            println!("Running lua file...");
            // TODO change the path to the result build path
            Command::new("lua")
                .arg(write_path)
                .spawn()
                .expect("Failed to run lua interperter on input file");
        }
    };

    Ok(())
}
