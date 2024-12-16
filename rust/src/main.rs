use std::path::Path;

fn main() {
    let p = Path::new(".");
    println!("{:?}", std::path::absolute(p).expect("Should not fail."))
}
