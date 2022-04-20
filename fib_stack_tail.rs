use std::collections::HashMap;
use std::iter::FromIterator;

use Expression::{
    Number, Var, 
    Sub, Add, JNE, 
    Function, Call, Rec, Return
};

#[derive(Clone)]
enum Expression {
    Function(i32, i32),
    Call(i32, i32),
    JNE(i32),
    Number(i32),
    Var(i32),
    Sub, 
    Add, 
    Rec,
    Return
}
// const LOOP_COUNT:i32 = 4000000;

fn eval(
    bytecode : &Vec<Expression>,
    fmap: &HashMap<i32, i32>,
    stack: &mut Vec<i32>)-> i32 {
    
    // let mut loop_count = 0;
    let blength:i32 = bytecode.len() as i32;
    
    let mut pointer:i32 = 0;
    let mut rstack: Vec<i32> = Vec::new();
    let mut vmap: HashMap<i32,i32> = HashMap::new();
    let mut vbackup: Vec<HashMap<i32,i32>> = Vec::new();
    
    // println!("{} - block#{} [eval] ==== START ====", &loop_count, &pointer);
    loop {
        if pointer < blength && pointer != -1 {
            // if loop_count > LOOP_COUNT {return -1}
            // print!("{} - block#{} stacks[{}]: ", &loop_count, &pointer, &stack.len());
            execute(&mut vmap, fmap, &bytecode[pointer as usize],
                 stack, &mut rstack, &mut vbackup, &mut pointer);
            pointer += 1;
            // loop_count += 1;
        } 
        else if stack.len() > 0 {
            let result = stack.pop().unwrap();
            return result;
        } else { 
            return 0 
        }
    }

}

/// execute expression by vmap && fmap
fn execute(
    vmap: &mut HashMap<i32, i32>,
    fmap: &HashMap<i32, i32>,
    exp: &Expression, 
    stack: &mut Vec<i32>,
    rstack: &mut Vec<i32>,
    vbackup: &mut Vec<HashMap<i32, i32>>,
    pointer: &mut i32) {
    match exp {
        Number(num) => {
            // println!("[number] {}", &num);
            stack.push(*num);
        }, 
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
        JNE(label) => {
            let x = stack.pop().unwrap();
            let y = stack.pop().unwrap();
            if x != y {
                *pointer = *label;
            }
            // println!("[not_equal] {} != {} > jump #{}", &x, &y, &label);
        },
        Var(id) => {
            let v = vmap.get(&id).unwrap();
            stack.push(*v);
            // println!("[var] #{}={}", *id, &v);
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
        
        Function(_, n) => {
            // print!("[func(");
            // 
            // Restore args if vmap exist.
            if vmap.len() > 0 {
                vbackup.push(vmap.clone());
            }
            //
            let mut index = 0;
            loop {
                if index < *n {
                    let v = stack.pop().unwrap();
                    // print!(" {} ", &v);
                    vmap.insert(index, v);
                    index += 1;
                } else { 
                    break;
                }
            }
            // print!(")]");
            // println!();
        },
        Rec => {
            // println!("[rec]\n");
            rstack.push(*pointer);
            *pointer = -1;
        },
        Call(id, args_len) => {
            // println!("[call] f#{}({}) @{}\n", &id, &args_len, &pointer);
            let f = &*fmap.get(&id).unwrap();
                    // .expect(&format!("function not found: {}", id));
            if stack.len() < *args_len as usize {
                // println!("[call] not enough item on stack !");
                return;
            }
            // save pointer, so we can return from a call.
            rstack.push(*pointer);
            *pointer = f-1;
        }
    }
}

fn main() {
    let bytecode = vec![
        // fib (n, a, b)
        Function(0x1, 3),   // 0
        // n != 0 ?
        Number(0),          // 1
        Var(0),             // 2
        JNE(5),             // 3
        Var(1),             // 4
        Return,             // 5
       // n != 1 ?
        Number(1),          // 6
        Var(0),             // 7
        JNE(10),            // 8
        Var(2),             // 9
        Return,             // 10
        // f1 = (a + b) 
        Var(2),             // 11
        Var(1),             // 12
        Add,                // 13
        // f2 = b
        Var(2),             // 14
        // f3 = n - 1
        Number(1),          // 
        Var(0),             // 
        Sub,                // 
        // f(f3. f2. f1)
        Rec,                // 
        Return              // 
    ];
    let fmap: HashMap<i32,i32> = HashMap::from_iter(vec![(0x1, 0)]);
    let mut stack:Vec<i32> = vec![1, 0, 30]; // b a n f => f( n a b)

    // let result = 
    eval(&bytecode, &fmap, &mut stack);
    // println!("result = {}", &result);
}