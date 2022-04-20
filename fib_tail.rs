fn fib(n: u32, a: u32, b: u32) -> u32 {
    if n == 0  { a }
    else if n == 1 { b }
    else { 
        return fib (n - 1, b, a + b);       
    }    
}

fn main () {
   let r =  fib(30, 0, 1);
    // println!("acc = {}", r);
}