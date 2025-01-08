[ -d "/path/to/dir" ] && rm ./build/* && rm -rf ./build
mkdir ./build

rustc fib.rs -o ./build/fib
rustc fib_tail.rs -o ./build/fib_tail
rustc fib_tree.rs -o ./build/fib_tree
rustc fib_tree_tail.rs -o ./build/fib_tree_tail
rustc fib_stack.rs -o ./build/fib_stack
rustc fib_stack_tail.rs -o ./build/fib_stack_tail
rustc 1byte_format.rs -o ./build/1byte_format
llc -filetype=obj fib_llvm.ll -o ./build/fib_llvm.o && clang -no-pie ./build/fib_llvm.o -o ./build/fib_llvm && rm ./build/fib_llvm.o
zig build-exe fib.zig && mv fib ./build/fib_tail_zig && rm fib.o

