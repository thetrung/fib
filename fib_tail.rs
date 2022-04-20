fn fib(n: i128, a: i128, b: i128) -> i128 {
    if n == 0  { a }
    else if n == 1 { b }
    else { 
        return fib (n - 1, b, a + b);       
    }    
}

fn main () {
   let r =  fib(100, 0, 1);
    // println!("acc = {}", r);
}