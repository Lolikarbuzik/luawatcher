mod functions;
mod variables;

// TODO revise this since probably local parsers for scanning for local vars and fns so why use global fns?

pub use variables::global_variables;
pub use variables::local_variables;

pub use functions::global_functions;
pub use functions::local_functions;
