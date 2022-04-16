use std::collections::HashMap;
use std::iter::FromIterator;

use Expression::{
    Number, Var, 
    Sub, Add, NotEqual, 
    Function, Call, Return
};

#[derive(Clone)]
enum Expression {
    Function(i32, i32),
    Call(i32, i32),
    NotEqual(i32),
    Number(i32),
    Var(i32),
    Sub, 
    Add, 
    Return
}

const LOOP_COUNT:i32 = 4000000;

fn eval(
    bytecode : &Vec<Expression>,
    fmap: &HashMap<i32, i32>,
    stack: &mut Vec<i32>)-> i32 {
    println!("[eval] ========= start =========");
    
    let mut loop_count = 0;
    let blength:i32 = bytecode.len() as i32;
    
    let mut pointer:i32 = 0;
    let mut rstack: Vec<i32> = Vec::new();
    let mut vmap: HashMap<i32,i32> = HashMap::new();
    let mut vbackup: Vec<HashMap<i32,i32>> = Vec::new();
    
    loop {
        if pointer < blength && pointer != -1 {
            // if loop_count > LOOP_COUNT {return -1}
            print!("{} - block#{} stacks[{}]: ", &loop_count, &pointer, &stack.len());
            execute(&mut vmap, fmap, 
                &bytecode[pointer as usize],
                 stack, &mut rstack, &mut vbackup, &mut pointer);
            pointer += 1;
            // counting 
            loop_count += 1;

        } else if stack.len() > 0 {
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
            println!("[number] {}", &num);
            stack.push(*num);
        }, 
        Sub => {
            let x = stack.pop().unwrap();
            let y = stack.pop().unwrap();
            println!("[sub] {} - {}", &x, &y);
            stack.push(x-y);
        },
        Add => {
            let x = stack.pop().unwrap();
            let y = stack.pop().unwrap();
            println!("[add] {} + {}", &x, &y);
            stack.push(x+y);
        },
        NotEqual(label) => {
            let _top = stack.len()-1;
            let x = stack.pop().unwrap();
            let y = stack.pop().unwrap();
            if x != y {
                *pointer = *label;
            }
            println!("[not_equal] {} != {} > jump #{}", &x, &y, &label);
        },
        Var(id) => {
            // println!("[var]");
            let v = vmap.get(&id).unwrap();
            stack.push(*v);
            println!("[var] #{}={}", *id, &v);
        },
        Return => {
            // Restore vmap
            if vbackup.len() > 0 {
                *vmap = vbackup.pop().unwrap();
                //
                // Restore pointer to where it was called
                let callback = rstack.pop().unwrap();
                println!("[return] @{} callback > #{}", &pointer, callback);
                *pointer = callback;
            }
        },
        
        Function(_, n) => {
            print!("[func(");
            // TODO: 
            // Need some ways to restore args if vmap exist.
            if vmap.len() > 0 {
                vbackup.push(vmap.clone());
            }
            //
            let mut index = 0;
            loop {
                if index < *n {
                    let v = stack.pop().unwrap();
                    print!(" {} ", &v);
                    vmap.insert(index, v);
                    index += 1;
                } else { 
                    break;
                }
            }
            print!(")]");
            println!();
        },
        Call(id, args_len) => {
            println!("[call] f#{}({}) @{}\n", &id, &args_len, &pointer);
            let f = &*fmap.get(&id)
                    .expect(&format!("function not found: {}", id));
            if stack.len() < *args_len as usize {
                println!("[call] not enough item on stack !");
                return;
            }
            // save pointer, so we can return from a call.
            rstack.push(*pointer);
            *pointer = *f-1;
        }
    }
}

fn main() {
    let bytecode = vec![
        Function(0x1, 1),   // 0
        // 0 != arg ?
        Number(0),          // 1
        Var(0),             // 2
        NotEqual(5),        // 3
        Number(0),          // 4
        Return,             // 5
       // 1 != arg ?
        Number(1),          // 6
        Var(0),             // 7
        NotEqual(10),       // 8
        Number(1),          // 9
        Return,             // 10
       // arg - 1 
        Number(1),          // 11
        Var(0),             // 12
        Sub,                // 13
        Call(0x1, 1),       // 14
        // arg - 2
        Number(2),          // 15
        Var(0),             // 16
        Sub,                // 17
        Call(0x1, 1),       // 18
        Add,                // 19
        Return              // 20
    ];
    let mut fmap: HashMap<i32,i32> = // function 0x1 at vec![0]
        HashMap::from_iter(vec![(0x1, 0)]);
    let mut stack:Vec<i32> = vec![30]; // result = 2
    println!("result = {}",eval(&bytecode, &mut fmap, &mut stack));
}