type opcode =
  | Halt
  | Push of int
  | Add
  | Sub
  | Mul
  | Div
  | Print

type vm = {
  mutable stack : int list;
  mutable ip : int;
  program : opcode array;
}

let create_vm program = {
  stack = [];
  ip = 0;
  program;
}

let push vm value =
  vm.stack <- value :: vm.stack

let pop vm =
  match vm.stack with
  | [] -> failwith "Stack underflow"
  | x :: xs ->
      vm.stack <- xs;
      x

let run vm =
  let running = ref true in
  while !running do
    if vm.ip >= Array.length vm.program then
      failwith "Instruction pointer out of bounds";

    match vm.program.(vm.ip) with
    | Halt ->
        running := false

    | Push value ->
        push vm value;
        vm.ip <- vm.ip + 1

    | Add ->
        let b = pop vm in
        let a = pop vm in
        push vm (a + b);
        vm.ip <- vm.ip + 1

    | Sub ->
        let b = pop vm in
        let a = pop vm in
        push vm (a - b);
        vm.ip <- vm.ip + 1

    | Mul ->
        let b = pop vm in
        let a = pop vm in
        push vm (a * b);
        vm.ip <- vm.ip + 1

    | Div ->
        let b = pop vm in
        let a = pop vm in
        if b = 0 then failwith "Division by zero";
        push vm (a / b);
        vm.ip <- vm.ip + 1

    | Print ->
        let value = pop vm in
        Printf.printf "%d\n" value;
        vm.ip <- vm.ip + 1
  done

(* Program: (10 + 20) * 2 = 60 *)
let program = [|
  Push 10;
  Push 20;
  Add;
  Push 2;
  Mul;
  Print;
  Halt;
|]

let () =
  let vm = create_vm program in
  run vm
