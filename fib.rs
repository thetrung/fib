fn main () {
    fib(100);
}

fn fib(n: i128) -> i128 {
    match n {
        0 => return 0,
        1 => return 1,
        _ => return fib(n - 1) + fib(n - 2),
    }
}