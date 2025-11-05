use std::mem::size_of;
use std::mem::size_of_val;
use std::collections::HashMap;

use Expression::{
   // 0-1-2
   One, Zero, Two,
    
   // 10 args
   A0,A1,A2,//A3,A4,A5,A6,A7,A8,A9,
   U0, U3, U9, U15,

   // 100 registers
//    U0,U1,U2,U3,U4,U5,U6,U7,U8,U9,
//    U10,U11,U12,U13,U14,U15,U16,U17,U18,U19,
//    U20,U21,U22,U23,U24,U25,U26,U27,U28,U29,
//    U30,U31,U32,U33,U34,U35,U36,U37,U38,U39,
//    U40,U41,U42,U43,U44,U45,U46,U47,U48,U49,
//    U50,U51,U52,U53,U54,U55,U56,U57,U58,U59,
//    U60,U61,U62,U63,U64,U65,U66,U67,U68,U69,
//    U70,U71,U72,U73,U74,U75,U76,U77,U78,U79,
//    U80,U81,U82,U83,U84,U85,U86,U87,U88,U89,
//    U90,U91,U92,U93,U94,U95,U96,U97,U98,U99,

   // instructions
   Function, Call, Rec, Return,
   // branch
   JNE,
   // types
//    Integer, String, Double,

   // Operators
   Add, Sub, //Mul, Div, 
};

// enum Test { Add, Sub, Div, Mul,  Number, Var, 
//     JNE, 
//     Function, Call, 
//     Rec, Return 
// }

#[derive(Clone,Debug)]
enum Expression {
    // 0-1-2
    One, Zero, Two,
    
    // 10 args mA
    A0,A1,A2,//A3,A4,A5,A6,A7,A8,A9,
    U0, U3, U9, U15,

    // instructions
    Function, Call, Rec, Return,
    // branch
    JNE,
    // types
    // Integer, String, Double,
    
    // Operators
    Add, Sub, //Mul, Div, 
}

// const MAX_INSTRUCTIONS:i32 = 40000;

fn eval(
    bytecode : &Vec<Expression>,
    stack: &mut Vec<i128>)-> i128 {
    
    let mut function_call = 0;
    let mut instruction_count = 0;
    let blength:i128 = bytecode.len() as i128;
    
    let mut pointer:i128 = 0;
    let mut rstack: Vec<i128> = Vec::new();
    let mut vmap: HashMap<i128,i128> = HashMap::new();
    let mut fmap: HashMap<i128, i128> = HashMap::new();
    let mut vbackup: Vec<HashMap<i128,i128>> = Vec::new();
    
    // println!("{} - block#{} [eval] ==== START ====", &instruction_count, &pointer);
    loop {
        if pointer < blength && pointer != -1 {
            // if instruction_count > MAX_INSTRUCTIONS {return -1}
            // println!("{} - block#{} stacks[{}]: ", &instruction_count, &pointer, &stack.len());
            execute(
                &mut vmap, &mut fmap, &bytecode[pointer as usize],
                 stack, &mut rstack, &mut vbackup, &mut pointer, 
                 &mut function_call);
            pointer += 1;
            instruction_count += 1;
        } 
        else if stack.len() > 0 {
            // println!("function calls/instructions: {}/{}", 
            // &function_call,&instruction_count);
            let result = stack.pop().unwrap();
            return result;
        } else { 
            return 0
        }
    }
}

/// execute expression by vmap && fmap
fn execute(
    vmap: &mut HashMap<i128, i128>,
    fmap: &mut HashMap<i128, i128>,
    exp: &Expression, 
    stack: &mut Vec<i128>,
    rstack: &mut Vec<i128>,
    vbackup: &mut Vec<HashMap<i128, i128>>,
    pointer: &mut i128,
    function_call: &mut i128) {
    match exp {
        Two => stack.push(2), 
        One => stack.push(1),
        Zero => stack.push(0), 

        A0 => stack.push(*vmap.get(&0).unwrap()),
        A1 => stack.push(*vmap.get(&1).unwrap()),
        A2 => stack.push(*vmap.get(&2).unwrap()),

        U0 => stack.push(0),
        U3 => stack.push(3),
        U9 => stack.push(8),
        U15 => stack.push(14),

        Sub => {
            let x = stack.pop().unwrap();
            let y = stack.pop().unwrap();
            // println!("[sub] {} - {}", &x, &y);
            stack.push(x-y);
        },
        Add => {
            let x = stack.pop().unwrap();
            let y = stack.pop().unwrap();
            // println!("[add] {} + {}", &x, &y);
            stack.push(x+y);
        },
        JNE => {
            // print!("\n[not_equal] ");
            let label = stack.pop().unwrap();
            let x = stack.pop().unwrap();
            let y = stack.pop().unwrap();
            if x != y {
                *pointer = label;
            }
            // print!("{} != {} > jump #{}\n", &x, &y, &label);
        },

        Return => {
            // Restore vmap
            if vbackup.len() > 0 {
                *vmap = vbackup.pop().unwrap();
                //
                // Restore pointer to where it was called
                let callback = rstack.pop().unwrap();
                // println!("[return] @{} callback > #{}", &pointer, callback);
                *pointer = callback;
            } else {
                // println!("[return]\n");
            }
        },
        
        Function => {
            // print!("[func]");
            // 
            let fid = stack.pop().unwrap();
            // Cache into fmap if new: 
            if !fmap.contains_key(&fid) {
                let ptr = pointer.clone() + 1;
                fmap.insert(fid, ptr);
                // print!(" new#{:#02x}@ptr={} ", &fid, &ptr);
            }
            // print!("(");
            // Restore args if vmap exist.
            if vmap.len() > 0 {
                vbackup.push(vmap.clone());
            }
            // args amount
            let mut index = 0;
            let n = stack.pop().unwrap();
            loop {
                if index < n {
                    let v = stack.pop().unwrap();
                    // print!(" {} ", &v);
                    vmap.insert(index, v);
                    index += 1;
                } else { 
                    break;
                }
            }
            // counting loop
            *function_call += 1;
            // print!(")");
            // println!();
        },
        // [rec]: will be faster than call for ignoring function lookup.
        Rec => { 
            // println!("[rec]\n");
            rstack.push(*pointer);
            *pointer = -1;
        },
        Call => {
            let id = stack.pop().unwrap();
            // println!("[call] f#{} @{}\n", &id, &pointer);
            let f = &*fmap.get(&id).unwrap();
                    // .expect(&format!("function not found: {}", id));
            // save pointer, so we can return from a call.
            rstack.push(*pointer);
            *pointer = f-1;
        }
    }
}

fn main() {
    //
    // Version fib (n)
    //
    // let bytecode = vec![
    //     // fib (n, a, b)
    //     // 3 args, 0x0 index, function()
    //     One, U0, Function,  // 0
    //     // n != 0 ?
    //     Zero,      // 1
    //     A0,        // 2
    //     U9,JNE,       // 3
    //     Zero,       // 4
    //     Return,             // 5
    //    // n != 1 ?
    //     One,       // 6
    //     A0,            // 7
    //     U15,JNE,           // 8
    //     One,            // 9
    //     Return,             // 10
    //     // f1 = f(n - 1) 
    //     One,            // 11
    //     A0,            // 12
    //     Sub,                // 13
    //     Rec,
    //      // f2 = (n - 2) 
    //     Two,            // 11
    //     A0,            // 12
    //     Sub,                // 13
    //     Rec,                // 
    //     // f1 + f2
    //     Add,
    //     Return,
    // ];

    //
    // Version fib (n,a,b)
    //
    let bytecode = vec![
        // fib (n, a, b)
        // 3 args, 0x0 index, function()
        U3, U0, Function,  // 0
        // n != 0 ?
        Zero,      // 1
        A0,        // 2
        U9,JNE,       // 3
        A1,       // 4
        Return,             // 5
       // n != 1 ?
        One,       // 6
        A0,            // 7
        U15,JNE,           // 8
        A2,            // 9
        Return,             // 10
        // f1 = (a + b) 
        A1,            // 11
        A2,            // 12
        Add,                // 13
        // f2 = b
        A2,            // 14
        // f3 = n - 1
        One,         // 
        A0,            // 
        Sub,                // 
        // f(f3. f2. f1)
        Rec,
        // U0, Call,            // 
    ];
    // println!("Expression enum = {:?} bytes", size_of::<Expression>());
    // println!("Total bytecode = {} items / {} bytes", &bytecode.len() ,size_of_val(&bytecode));

    let mut new_stack:Vec<i128> = vec![1, 0, 100]; // b a n f => f( n a b)
    // let mut new_stack:Vec<i128> = vec![30]; // b a n f => f( n a b)

    // let result = 
    eval(&bytecode, &mut new_stack);
    // println!("result = {}", &result);
}
