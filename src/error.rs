use std::process::exit;

// Wow
pub fn perror(msg: &str) {
    println!("Exception found: {msg}");
    exit(1);
}
