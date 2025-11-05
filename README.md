# fib
Various approach on core VM implementation with Fibonacci speed test on various languages & VM implementations.

### Top-4 native result 
include FASM, LLVM-IR, Zig, Odin, Rust, Ocaml(vm), LuaJIT & Lua implementation, which I use to learn more about how those languages is so fast & how performance was different among them.

#### LLVM version : can correctly compute 128-bit number just like Zig/Rust can without much troubles, but what it can't do yet was printing result in decimal format, since that require manually converting 128-bit data into decimal string before calling printf() - which only support upto 64-bit number. (can compute 128-bit but can't print)

#### FASM version : include a native number-2-ASCII converter but like LLVM version, it can't print result above 64-bit limit yet. so Fib(93) was pretty much the current testing amount for languages. (can print theorically, but can't compute 128-bit yet)

#### Rust/Zig version : are just fine with both computation & printing due to built-in support. 

#### Ocaml/VM version : was suprisingly fast on Linux/Intel x86-64 without much optimization yet but slower on MacOS/M4. But still in range of Lua ~ LuaJIT.

#### Disabled Printing : I disabled all printing except `FASM version` since it was too fast with even printing so I won't remove it until some random languages can beat it ;)

This is my test result for `Fib(90)` on `Ubuntu 26.04` with `intel i5-1135G7 @ 4200Mhz` :

![alt](https://github.com/thetrung/fib/blob/master/result_preview.png)

- With fib(90, 0, 1) on MacOS with `hyperfine --warmup 10` : 

  Summary
  ./fib_tail_llvm ran
    1.18 ± 0.08 times faster than ./fib_tail_odin
    1.20 ± 0.09 times faster than ./fib_tail_rust
    1.21 ± 0.18 times faster than ./fib_tail_zig
    1.38 ± 0.18 times faster than luajit fib_tail_lua.jit
    1.43 ± 0.10 times faster than lua fib_tail_lua.lua
    1.48 ± 0.10 times faster than ./fib_tail_ml
    1.57 ± 0.11 times faster than ./fib_tail_ocaml



### Conclusion 
When there's no (or less) difference in algorithm/compiler optimization, the direct call from a series of instructions could be just as fast as native code or JITed, bytecode execution.
