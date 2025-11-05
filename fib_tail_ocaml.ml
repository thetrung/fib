type opcode =
  | HALT
  | MOV_REG_REG of int * int     (* dst, src *)
  | LOAD_IMM of int * int        (* dst, imm *)

  | ADD of int * int * int       (* src1, src2, dst *)
  | SUB of int * int * int
  | MUL of int * int * int
  | DIV of int * int * int
  | INC of int 
  | DEC of int

  | LABEL of string              (* imm *)
  | JMP of int                   (* imm *)
  | CMP_IMM_IMM of int * int     (* imm, imm *)
  | CMP_REG_REG of int * int     (* reg, reg *)
  | CMP_REG_IMM of int * int     (* reg, imm *)
  | JMP_EQUAL of int             (* imm *)
  | JMP_LESSER of int            (* imm *)
  | JMP_GREATER of int           (* imm *)

  | PRINT of int          (* reg *)

type vm = {
  mutable registers : int array;
  mutable flags : int array;
  mutable ip : int;
  mutable debug : bool;
  program : opcode array;
}

let create_vm program = {
  registers = Array.make 8 0;
  flags = Array.make 3 0;
  ip = 0; debug = false;
  program;
}

let is_equal, is_greater, is_lesser = 0,1,2
let ax, bx, cx, dx, ex = 0,1,2,3,4
(* NOTE :
 * Need a Jump Table already : to store Labels position specifically.
 * Need SFR for CMP Flags. 
 *)

let run vm =
  let len = Array.length vm.program in
  if vm.debug then Printf.printf "\nBEGIN (%d instructions)\n" len;
  let rec loop () =
    if vm.ip >= len then () else
    if vm.debug then 
      Printf.printf "OPCODE: %d\n[ %d | %d | %d | %d ]\n" vm.ip
      vm.registers.(ax) vm.registers.(bx) vm.registers.(cx) vm.registers.(dx);
    match vm.program.(vm.ip) with
    | HALT -> ()
    | MOV_REG_REG (dst, src) ->
        vm.registers.(dst) <- vm.registers.(src);
        vm.ip <- vm.ip + 1;
        loop ()
    | LOAD_IMM (dst, imm) ->
        vm.registers.(dst) <- imm;
        vm.ip <- vm.ip + 1;
        loop ()
    | ADD (src1, src2, dst) ->
        vm.registers.(dst) <- vm.registers.(src1) + vm.registers.(src2);
        vm.ip <- vm.ip + 1;
        loop ()
    | SUB (src1, src2, dst) ->
        vm.registers.(dst) <- vm.registers.(src1) - vm.registers.(src2);
        vm.ip <- vm.ip + 1;
        loop ()
    | MUL (src1, src2, dst) ->
        vm.registers.(dst) <- vm.registers.(src1) * vm.registers.(src2);
        vm.ip <- vm.ip + 1;
        loop ()
    | DIV (src1, src2, dst) ->
        if vm.registers.(src2) = 0 then failwith "Division by zero"
        else vm.registers.(dst) <- vm.registers.(src1) / vm.registers.(src2);
        vm.ip <- vm.ip + 1;
        loop ()
    | INC src -> 
        vm.registers.(src) <- vm.registers.(src) + 1;
        vm.ip <- vm.ip + 1;
        loop ()
    | DEC src -> 
        vm.registers.(src) <- vm.registers.(src) - 1;
        if vm.debug then Printf.printf "DEC => %d\n" vm.registers.(src);
        vm.ip <- vm.ip + 1;
        loop ()
    | PRINT reg ->
        Printf.printf (if vm.debug then "PRINT: %d\n" else "%d\n") vm.registers.(reg);
        vm.ip <- vm.ip + 1;
        loop ()
    | LABEL name ->
        if vm.debug then Printf.printf "\nLABEL: %s @ %d\n" name vm.ip;
        vm.ip <- vm.ip + 1;
        loop ()
    | JMP ip -> 
        vm.ip <- ip;
        loop ()
    | JMP_EQUAL ip ->
        if vm.flags.(is_equal) == 1 
        then vm.ip <- ip
        else vm.ip <- vm.ip + 1;
        loop ()
    | JMP_LESSER ip ->
        if vm.flags.(is_lesser) == 1 
        then vm.ip <- ip
        else vm.ip <- vm.ip + 1;
        loop ()
    | JMP_GREATER ip ->
        if vm.flags.(is_greater) == 1 
        then vm.ip <- ip
        else vm.ip <- vm.ip + 1;
        loop ()
    | CMP_REG_REG (src1, src2) -> 
      let regs = vm.registers in
        if regs.(src1) == regs.(src2) then vm.flags.(is_equal) <- 1 else 
        if regs.(src1) > regs.(src2) then vm.flags.(is_greater) <- 1 else 
        if regs.(src1) < regs.(src2) then vm.flags.(is_lesser) <- 1 else 
          failwith "Unsupported CMP instruction.";
        vm.ip <- vm.ip + 1;
        loop ()
    | CMP_IMM_IMM (imm1, imm2) -> 
        if imm1 == imm2 then vm.flags.(is_equal)   <- 1 else 
        if imm1 >  imm2 then vm.flags.(is_greater) <- 1 else 
        if imm1 <  imm2 then vm.flags.(is_lesser)  <- 1 else 
          failwith "Unsupported CMP instruction.";
        vm.ip <- vm.ip + 1;
    | CMP_REG_IMM (src, imm) -> 
      let regs = vm.registers in
        if regs.(src) == imm then vm.flags.(is_equal)   <- 1 else 
        if regs.(src) >  imm then vm.flags.(is_greater) <- 1 else 
        if regs.(src) <  imm then vm.flags.(is_lesser)  <- 1 else 
          failwith "Unsupported CMP instruction.";
        vm.ip <- vm.ip + 1;
        loop ()
  in
  loop ();
  if vm.debug then Printf.printf "\n== END PROGRAM == \n"

let () = 
  let fib = [|
    LOAD_IMM (ax, 0);          (* a = 0 *)
    LOAD_IMM (bx, 1);          (* b = 1 *)
    LOAD_IMM (cx, 90);          (* c = 10 *)
    LABEL("Entry");
    CMP_REG_IMM (cx, 0);       (* c == 0 ? *)
    JMP_EQUAL (13);            (* return a *)
    CMP_REG_IMM (cx, 1);       (* c == 1 ? *)
    JMP_EQUAL (13);            (* return b *)
    MOV_REG_REG (dx, ax);      (* d = a *)
    MOV_REG_REG (ax, bx);      (* a = b *)
    ADD (dx, bx, bx);          (* b = d + b *)
    DEC (cx);                  (* c = c - 1 *)
    JMP (3);                   (* -> Entry 3 *)
    LABEL ("Exit");
    PRINT (bx);                (* print a *)
    HALT;                      (* end program *)
  |] in let vm = create_vm fib in run vm;
