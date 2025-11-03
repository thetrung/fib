package fib_tail
import "core:fmt"

fib :: proc (n: i128, a : i128, b: i128) -> i128 {
    if n == 0 { return a }
    if n == 1 { return b }
    else {
        return fib (n-1, b, a + b)
    } 
}
main :: proc (){
    result := fib(93, 0, 1)
    fmt.println (result)
}