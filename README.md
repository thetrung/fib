# fib
Various approach on core VM implementation with speed test on Fibonacci function.

### Performance result
I will compare `lua`, `luaJIT`, `luavm` with my core interpreter `rust_stack`, `rust_tree` and the native `rust_native` and later, same thing, same evaluation algoritm with a `tail call optimization` version for all of them (six in total). As `lua`, `luaJIT`, `luavm` share the same `fib.lua`, my 3 impls will have their custom rival with `_tail` postfix.

- With recursion call :

        luajit 
        0.011  

        rust_native 
        0.012
        
        lua 
        0.078

        luavm 
        1.925

        rust_stack 
        7.232 

        rust_tree 
        35.151

- With `tail call optimization`: 

        luajit 
        0.003

        rust_stack_tail 
        0.003

        rust_native_tail 
        0.003

        lua 
        0.004

        rust_tree_tail 
        0.004

        luavm 
        0.006
        
Which mean, my `rust_stack_tail` could be as fast as `luajit` or `rust_native_tail` !

- With `i128` to calculate fib(100): 


        luajit
        0.002

        lua
        0.002

        luavm
        0.005
        
        rust_native_tail
        0.005

        rust_stack_tail
        0.007

        rust_tree_tail
        0.008

This is where those compilers did some tricky optimization again, perhaps, like converting into iterative loop instead of recursion.

### Conclusion 
When there's no (or less) difference in algorithm/compiler optimization, the direct call from a series of instructions could be just as fast as native code or JITed, bytecode execution.
