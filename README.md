# fib
Various approach on core VM implementation with speed test on Fibonacci function.

### Performance result

    Running luavm on ./benchmarks/fib.lua
    Mean: 1.809, Std.Dev: 0.043, Margin of error: 0.049536955546339335

    Running luajit on ./benchmarks/fib.lua
    Mean: 0.011, Std.Dev: 0.001, Margin of error: 0.0011520222220078916

    Running lua on ./benchmarks/fib.lua
    Mean: 0.073, Std.Dev: 0.005, Margin of error: 0.0057601111100394585

    Running rust_native on ./benchmarks/fib.lua
    Mean: 0.011, Std.Dev: 0.001, Margin of error: 0.0011520222220078916

    Running rust_stack_tail on ./benchmarks/fib.lua
    Mean: 0.003, Std.Dev: 0.001, Margin of error: 0.0011520222220078916
    

With `tail call optimization`, `rust_stack` as `rust_stack_tail` could really be faster than `luajit` and `rust_native` by 3.66 times ! While also faster than `luavm` implemented in `rust` for 603 times.

