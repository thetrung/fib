# fib
Various approach on core VM implementation with Fibonacci speed test on top-3 language implementations.

### Top-3 native result 
include Zig, Rust & LLVM-IR implementation, which I use to learn more about how those languages is so fast. Guess Zig is both simpler to learn & faster to code.

![benchmark](https://github.com/thetrung/fib/blob/master/Zig_Rust_LLVM.png)



### VMs result
I compare `lua`, `luaJIT`, `luavm` with my core evaluation of `rust_stack`, `rust_tree`, `1byte_format` and the native `rust_native`. Then, the same thing, with a `tail call optimization` version for all of them (six in total). 

As `lua`, `luaJIT`, `luavm` share the same `fib.lua`, while my impls will have their custom rival with `_tail` postfix.

- With recursion call => fib(30):

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

        1byte_format
        9.826

        rust_tree 
        35.151


- With `tail call optimization` => fib(30, 0, 1): 

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

        1byte_format
        0.004

        luavm 
        0.006
        

- With `i128` + TCO => fib(100, 0, 1) with 10 runs : 

        rust_native_tail
        0.003

        luajit
        0.004

        lua
        0.004

        1byte_format
        0.004

        rust_stack_tail
        0.004

        luavm
        0.007

        rust_tree_tail
        0.008

I think this is where compilers did some tricky optimization to turn recursive call version into tail call optimization version. Which is why their non-TCO and TCO version have close results while I have to optimize the common version to speed up.

`1byte_format` && `rust_stack_tail` are the same 100 loops like every others but `1byte_format` have 400 more instructions to execute than `rust_stack_tail`.

### Conclusion 
When there's no (or less) difference in algorithm/compiler optimization, the direct call from a series of instructions could be just as fast as native code or JITed, bytecode execution.
