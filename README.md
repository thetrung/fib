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
        1.18 ± 0.10 times faster than ./fib_tail_odin
        1.19 ± 0.16 times faster than ./fib_tail_zig
        1.20 ± 0.10 times faster than ./fib_tail_rust
        1.35 ± 0.11 times faster than luajit fib_tail_lua.jit
        1.43 ± 0.12 times faster than lua fib_tail_lua.lua
        1.48 ± 0.19 times faster than ./fib_tail_ml
        1.56 ± 0.13 times faster than ./fib_tail_ocaml



### Conclusion 
- As Simple as possible => Best Performance.
- Everything need to be clarity before it can be fast. 
- Program/Bytecode as an `Int Array` is final goal for JIT VM.

### TODO 
For current VM on Ocaml it may just simply fulfill these things :

##### Encoding into `Int Array`
How final bytecode form actually is. 

##### Constant Pool as `Static Data Memory` 
indeed is like how PIC ref value to static data on Flash -> which we can simply access program data memory by VM pointer within region 🤷‍♂️ => So no need additional stuffs, just reorganize current core vm structure. 

##### Memory Allocation via `Dynamic Array` 
could be just 3 mutable Arrays : Int - Float - Char : Which is resizable, renewable, malloc on-demand in runtime, rely on ocaml GC. 

##### I/O & Interfaces
How it input/output & interact with outside libraries via Ocaml `Register.Call`. 

### Further Plan
For fastest thing we may want to compete with other poorly design languages nowadays (except Ocaml/Lua), I may just cheat it by compiling down directly to Assembly & call it a day. But in another hand, having a hot-reload VM within other game engines (while being more performant) is very much desirable. Especially when it is designed to handle `data-driven model` to let people that once love 8-bit era can do it again with much more simple & elegant way to create their things with joy and less hassle. Perhaps, with more modern stuffs like 2D/3D support.

Else, it still could serve as a foundation to build other languages on it : like non-GC but Region-based Auto-Free Memory - so people can ditch Rust for better mem model.