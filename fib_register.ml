type opcode =
  | Halt
  | Mov of int * int     (* dst, src *)
  | LoadI of int * int   (* dst, immediate *)
  | Add of int * int * int  (* src1, src2, dst *)
  | Sub of int * int * int
  | Mul of int * int * int
  | Div of int * int * int
  | Print of int          (* reg *)

type vm = {
  mutable registers : int array;
  mutable ip : int;
  program : opcode array;
}

let create_vm program = {
  registers = Array.make 8 0;
  ip = 0;
  program;
}

let run vm =
  let len = Array.length vm.program in
  let rec loop () =
    if vm.ip >= len then () else
    match vm.program.(vm.ip) with
    | Halt -> ()
    | Mov (dst, src) ->
        vm.registers.(dst) <- vm.registers.(src);
        vm.ip <- vm.ip + 1;
        loop ()
    | LoadI (dst, imm) ->
        vm.registers.(dst) <- imm;
        vm.ip <- vm.ip + 1;
        loop ()
    | Add (src1, src2, dst) ->
        vm.registers.(dst) <- vm.registers.(src1) + vm.registers.(src2);
        vm.ip <- vm.ip + 1;
        loop ()
    | Sub (src1, src2, dst) ->
        vm.registers.(dst) <- vm.registers.(src1) - vm.registers.(src2);
        vm.ip <- vm.ip + 1;
        loop ()
    | Mul (src1, src2, dst) ->
        vm.registers.(dst) <- vm.registers.(src1) * vm.registers.(src2);
        vm.ip <- vm.ip + 1;
        loop ()
    | Div (src1, src2, dst) ->
        if vm.registers.(src2) = 0 then failwith "Division by zero"
        else vm.registers.(dst) <- vm.registers.(src1) / vm.registers.(src2);
        vm.ip <- vm.ip + 1;
        loop ()
    | Print reg ->
        Printf.printf "%d\n" vm.registers.(reg);
        vm.ip <- vm.ip + 1;
        loop ()
  in
  loop ()

let () =
  let program = [|
    LoadI (0, 10);
    LoadI (1, 20);
    Add (0, 1, 2);
    LoadI (3, 2);
    Mul (2, 3, 4);
    Print 4;
    Halt;
  |] in
  let vm = create_vm program in
  run vm
