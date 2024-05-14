use std::{fs, io};

/// This functions converts the path `<dir>/*` to `build/*`
pub fn write_path(path: &str, content: String) -> io::Result<String> {
    let mut split = path
        .split("/")
        .map(|v| v.to_owned())
        .collect::<Vec<String>>();

    if split.len() >= 2 {
        for i in 2..split.len() {
            let cpath = "build/".to_owned() + &split.get(1..i).unwrap().join("/");
            let _ = fs::create_dir(cpath);
        }
        split.remove(0);
    }

    let write_path = "build/".to_owned() + &split.join("/");
    fs::write(&write_path, content)?;

    Ok(write_path)
}
