fn main () {
    fib(30);
}

fn fib(n: u32) -> u32 {
    match n {
        0 => return 0,
        1 => return 1,
        _ => return fib(n - 1) + fib(n - 2),
    }
}