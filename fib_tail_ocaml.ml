type opcode =
  | HALT
  | MOV_MEM_MEM of int * int    (* dst, src *)
  | EQU_IMM of int * int   (* dst, imm *)
  | LOAD_MEM_IMM of int * int   (* dst, imm *) 
  | MALLOC_INT of int    (* int    x [imm] *)

  | ADD of int * int       (* dst, src *)
  | SUB of int * int 
  | MUL of int * int 
  | DIV of int * int
  | INC of int 
  | DEC of int

  | LABEL of string              (* imm *)
  | JMP of int                   (* imm *)
  | CMP_IMM_IMM of int * int     (* imm, imm *)
  | CMP_MEM_MEM of int * int     (* reg, reg *)
  | CMP_MEM_IMM of int * int     (* reg, imm *)
  | JMP_EQUAL of int             (* imm *)
  | JMP_LESSER of int            (* imm *)
  | JMP_GREATER of int           (* imm *)

  | PRINT of int          (* reg *)

type vm = {
  mutable memory : int array;
  mutable flags : int array;
  mutable ip : int;
  mutable debug : bool;
  program : opcode array;
}

let create_vm program = {
  memory = Array.make 4 0;     (* only 4 registers *)
  flags = Array.make 3 0;
  ip = 0; debug = false;
  program;
}

(* Variables  *)
let a, b, c, d = 0,1,2,3

(* Comparisons  *)
let is_equal, is_greater, is_lesser = 0,1,2

(* 
 * NOTE :
 * Need a Jump Table : to store Labels position specifically. 
 *)
let run vm =
  let len = Array.length vm.program in
  if vm.debug then Printf.printf "\nBEGIN (%d instructions)\n" len;
  while vm.ip < len do
    if vm.debug then 
      Printf.printf "OPCODE: %d\n[ %d | %d | %d | %d ]\n" vm.ip
      vm.memory.(a) vm.memory.(b) vm.memory.(c) vm.memory.(d);
    match vm.program.(vm.ip) with
    | HALT -> vm.ip <- len + 1;
    | MOV_MEM_MEM (dst, src) ->
        vm.memory.(dst) <- vm.memory.(src);
        vm.ip <- vm.ip + 1;
    | EQU_IMM (dst, imm) ->
        vm.memory.(dst) <- imm;
        vm.ip <- vm.ip + 1;
    | LOAD_MEM_IMM (dst, imm) ->
        vm.memory.(dst) <- imm;
        vm.ip <- vm.ip + 1;
    | MALLOC_INT imm ->
        vm.memory <- Array.make imm 0;
        vm.ip <- vm.ip + 1;
    | ADD (dst, src) ->
        vm.memory.(dst) <- vm.memory.(dst) + vm.memory.(src);
        vm.ip <- vm.ip + 1;
    | SUB (dst, src) ->
        vm.memory.(dst) <- vm.memory.(dst) - vm.memory.(src);
        vm.ip <- vm.ip + 1;
    | MUL (dst, src) ->
        vm.memory.(dst) <- vm.memory.(dst) * vm.memory.(src);
        vm.ip <- vm.ip + 1;
    | DIV (dst, src) ->
        if vm.memory.(src) = 0 then failwith "Division by zero"
        else vm.memory.(dst) <- vm.memory.(dst) / vm.memory.(src);
        vm.ip <- vm.ip + 1;
    | INC src -> 
        vm.memory.(src) <- vm.memory.(src) + 1;
        vm.ip <- vm.ip + 1;
    | DEC src -> 
        vm.memory.(src) <- vm.memory.(src) - 1;
        if vm.debug then Printf.printf "DEC => %d\n" vm.memory.(src);
        vm.ip <- vm.ip + 1;
    | PRINT reg ->
        Printf.printf (if vm.debug then "PRINT: %d\n" else "%d\n") vm.memory.(reg);
        vm.ip <- vm.ip + 1;
    | LABEL name ->
        if vm.debug then Printf.printf "\nLABEL: %s @ %d\n" name vm.ip;
        vm.ip <- vm.ip + 1;
    | JMP ip -> 
        vm.ip <- ip;
    | JMP_EQUAL ip ->
        if vm.flags.(is_equal) == 1 
        then vm.ip <- ip
        else vm.ip <- vm.ip + 1;
    | JMP_LESSER ip ->
        if vm.flags.(is_lesser) == 1 
        then vm.ip <- ip
        else vm.ip <- vm.ip + 1;
    | JMP_GREATER ip ->
        if vm.flags.(is_greater) == 1 
        then vm.ip <- ip
        else vm.ip <- vm.ip + 1;
    | CMP_MEM_MEM (src1, src2) -> 
      let regs = vm.memory in
        if regs.(src1) == regs.(src2) then vm.flags.(is_equal) <- 1 else 
        if regs.(src1) > regs.(src2) then vm.flags.(is_greater) <- 1 else 
        if regs.(src1) < regs.(src2) then vm.flags.(is_lesser) <- 1 else 
          failwith "Unsupported CMP instruction.";
        vm.ip <- vm.ip + 1;
    | CMP_IMM_IMM (imm1, imm2) -> 
        if imm1 == imm2 then vm.flags.(is_equal)   <- 1 else 
        if imm1 >  imm2 then vm.flags.(is_greater) <- 1 else 
        if imm1 <  imm2 then vm.flags.(is_lesser)  <- 1 else 
          failwith "Unsupported CMP instruction.";
        vm.ip <- vm.ip + 1;
    | CMP_MEM_IMM (src, imm) -> 
      let regs = vm.memory in
        if regs.(src) == imm then vm.flags.(is_equal)   <- 1 else 
        if regs.(src) >  imm then vm.flags.(is_greater) <- 1 else 
        if regs.(src) <  imm then vm.flags.(is_lesser)  <- 1 else 
          failwith "Unsupported CMP instruction.";
        vm.ip <- vm.ip + 1;
  done;
  if vm.debug then Printf.printf "\n== END PROGRAM == \n";
  ()
  
let () = 
  let fib = [|
    EQU_IMM (a, 0);          (* a = 0 *)
    EQU_IMM (b, 1);          (* b = 1 *)
    EQU_IMM (c, 90);         (* c = 90 => 2880067194370816120 *)
    LABEL("Entry");
    CMP_MEM_IMM (c, 0);       (* c == 0 ? *)
    JMP_EQUAL (13);            (* return a *)
    CMP_MEM_IMM (c, 1);       (* c == 1 ? *)
    JMP_EQUAL (13);            (* return b *)
    MOV_MEM_MEM (d, a);      (* d = a *)
    MOV_MEM_MEM (a, b);      (* a = b *)
    ADD (b, d);              (* b = d + b *)
    DEC (c);                  (* c = c - 1 *)
    JMP (3);                   (* -> Entry 3 *)
    LABEL ("Exit");
    PRINT (b);                (* print a *)
    HALT;                      (* end program *)
  |] in let vm = create_vm fib in run vm;
