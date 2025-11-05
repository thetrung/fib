if [ "$(uname -s)" = "Linux" ]; then
  echo "Running on Linux"
elif ["$(uname -s)" = "Darwin" ]; then
  echo "Running on MacOS"
fi

[ -d "/path/to/dir" ] && rm ./build/* && rm -rf ./build
mkdir ./build

# unoptimized fib
# rustc fib.rs -o ./build/fib

# VM-like 
# rustc fib_tree.rs -o ./build/fib_tree
# rustc fib_tree_tail.rs -o ./build/fib_tree_tail
# rustc fib_stack.rs -o ./build/fib_stack
# rustc fib_stack_tail.rs -o ./build/fib_stack_tail
# rustc 1byte_format.rs -o ./build/1byte_format

# Top-4 native tail-call fib(90)
rustc fib_tail_rust.rs -o ./build/fib_tail_rust
llc -filetype=obj fib_tail_llvm.mlir -o ./build/fib_tail_llvm.o && clang ./build/fib_tail_llvm.o -o ./build/fib_tail_llvm && rm ./build/fib_tail_llvm.o
zig build-exe fib_tail_zig.zig && mv fib_tail_zig ./build/fib_tail_zig #&& rm fib_tail_zig.o
cd ./fib_tail_odin && odin build . && mv fib_tail_odin ../build/fib_tail_odin && cd ..
ocamlopt -o fib_tail_ocaml fib_tail_ocaml.ml && mv fib_tail_ocaml ./build/fib_tail_ocaml && rm -f *.cmx *.cmi *.o *.out
luajit -bg fib_tail_lua.lua fib_tail_lua.jit && mv fib_tail_lua.jit ./build/fib_tail_lua.jit 
cp fib_tail_lua.lua ./build
if [ "$(uname -s)" = "Linux" ]; then
    fasm fib_tail_fasm.asm && mv fib_tail_fasm ./build/fib_tail_fasm && chmod +x ./build/fib_tail_fasm
fi 

# Benchmark with hyperfine :
if [ hyperfine ]; then
    if [ "$(uname -s)" = "Linux" ]; then
      cd ./build && hyperfine --prepare 'echo test;sync;echo 3 | sudo tee /proc/sys/vm/drop_caches'  --warmup 10 -N './fib_tail_rust' './fib_tail_llvm' './fib_tail_zig' './fib_tail_odin' './fib_tail_ocaml' './fib_tail_fasm' 'luajit fib_tail_lua.jit' 'lua fib_tail_lua.lua'
    elif [ "$(uname -s)" = "Darwin" ]; then
      cd ./build && hyperfine --warmup 10 -N './fib_tail_rust' './fib_tail_llvm' './fib_tail_zig' './fib_tail_odin' './fib_tail_ocaml' 'luajit fib_tail_lua.jit'
    fi
    echo ''

    # Delete ?
    cd .. && rm ./build/* && rm -rf ./build
    echo 'Removed Build folder.'
fi
