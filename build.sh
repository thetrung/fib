[ -d "/path/to/dir" ] && rm ./build/* && rm -rf ./build
mkdir ./build

rustc fib.rs -o ./build/fib
rustc fib_tree.rs -o ./build/fib_tree
rustc fib_stack.rs -o ./build/fib_stack
