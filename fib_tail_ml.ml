let fib n =
  let rec loop a b = function
  | 0 -> a
  | 1 -> b 
  | n when n > 1 -> loop b (a + b) (n - 1)
  | _ -> raise (Invalid_argument "Error")
in loop 0 1 n
in
fib 90 
(* |> Printf.printf "result = %d" *)