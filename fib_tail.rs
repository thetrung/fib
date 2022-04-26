fn fib(n: i128, a: i128, b: i128, loop_count: &mut i128) -> i128 {
    *loop_count += 1;
    if n == 0  { a }
    else if n == 1 { b }
    else { 
        return fib (n - 1, b, a + b, loop_count);       
    }    
}

fn main () {
    let mut loop_count = 0;
   let r =  fib(100, 0, 1, &mut loop_count);
    // println!("acc = {} / loop: {}", r, loop_count);
}