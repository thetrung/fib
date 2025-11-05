fn main () {
    let mut _loop = 0;
    fib(100, &mut _loop);
    // println!("loop: {}", _loop);
}

fn fib(n: i128, _loop: &mut i128) -> i128 {
    *_loop += 1;
    match n {
        0 => return 0,
        1 => return 1,
        _ => return fib(n - 1, _loop) + fib(n - 2, _loop),
    }
}