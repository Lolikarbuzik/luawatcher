use regex::Regex;

use crate::datatypes::{LuaScope, LuaValue};

// i guess those fns can be recursive?
pub fn local_variables(content: &mut String, scope: &mut LuaScope) {
    let re = Regex::new(r"local ([^\s\n\r;]*)\s*=\s*([^\s\n\r;]*)").unwrap();
    for mat in re.captures_iter(content) {
        let var_name = mat.get(1).unwrap().as_str();
        // TODO parse this
        scope.push_str(var_name, LuaValue::Value);
    }
    *content = re
        .replace_all(content, "local $1 = ____LUAWATCHER:watch($2, \"$1\")")
        .to_string();

    // Updating local variables
    let re = Regex::new(r"([ \w\d\[\]]*?)\s*=[ ]([^\n\r;]*)").unwrap();
    for mat in re.captures_iter(&content.clone()) {
        let (str, [start, value]) = mat.extract::<2>();
        if start.starts_with("local ") {
            continue;
        }
        let expr_name = start.replace("local ", "");
        let mut split: Vec<String> = expr_name
            .split("[")
            .into_iter()
            .map(|v| v.trim().replace("]", ""))
            .collect();
        let mut index = split
            .clone()
            .last()
            .and_then(|v| {
                if split.len() < 2 {
                    return None;
                }
                split.remove(split.len() - 1);
                Some(v.trim().to_owned())
            })
            .unwrap_or("nil".to_owned());
        let var_name = split.join("");
        if !scope.contains(&var_name) {
            // println!("Got global var/undefined {var_name}");
            continue;
        }
        if index == var_name {
            index = "nil".to_owned();
        }
        // println!("VAR {var_name} EXPR {expr_name} TO {value} I {index}");
        // TODO if var_name is an array index convert var_name to array name and set key to index
        *content = content.replace(
            str,
            format!("____LUAWATCHER:__SET(\"{var_name}\", {index}, {value}, {var_name})\n{expr_name} = ____LUAWATCHER:watch({value}, \"{var_name}\")")
                .as_str(),
        );
    }
}
pub fn global_variables(content: &mut String, scope: &mut LuaScope) {}
