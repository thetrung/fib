use std::collections::HashMap;
use std::iter::FromIterator;

use Expression::{
    Number, Variable, 
    Sub, Add, /*Mul, Div,*/ Equal, 
    If, Function, Call, Return
};

#[derive(Clone)]
enum Expression {
    Call(i128, Vec<Box<Expression>>),
    Function(i128, Vec<Box<Expression>>, Box<Expression>),
    If(Box<Expression>, Box<Expression>, Box<Expression>), // if(cond, true, false)

    Number(i128),
    Return(Box<Expression>),
    Equal(Box<Expression>, Box<Expression>),
    Add(Box<Expression>, Box<Expression>),
    Sub(Box<Expression>, Box<Expression>),
    // Mul(Box<Expression>, Box<Expression>),
    // Div(Box<Expression>, Box<Expression>),
    Variable(i128)
}

fn make_closure(
    vmap: &HashMap<i128, i128>, 
    fmap: &HashMap<i128, Expression>, 
    args: Vec<Box<Expression>>) -> HashMap<i128, i128> {
    // argument index start from 1 
    let mut index = 1;
    let mut closure: HashMap<i128,i128> = HashMap::new();
    for arg in args {
        let v = evaluate(vmap, fmap, *arg);
        closure.insert(index, v);
        // println!("[make_closure] #{} = {}", &index, &v);
        index += 1;
    }
    return closure;
}

/// Evaluate expression by vmap && fmap
fn evaluate(vmap: &HashMap<i128, i128>, fmap: &HashMap<i128, Expression>, exp: Expression) -> i128 {
    match exp {
        Number(num) => num, 
        Sub(x, y) => evaluate(vmap, fmap, *x) - evaluate(vmap, fmap, *y),
        Add(x, y) => evaluate(vmap, fmap, *x) + evaluate(vmap, fmap, *y),
        // Mul(x, y) => evaluate(vmap, fmap, *x) * evaluate(vmap, fmap, *y),
        // Div(x, y) => evaluate(vmap, fmap, *x) / evaluate(vmap, fmap, *y),
        Equal(x, y) => {
            if evaluate(vmap, fmap, *x) == evaluate(vmap, fmap, *y) 
            { 1 } else { 0 }
        },
        Variable(id) => {
            *vmap.get(&id)
            .expect(&format!("variable not found: {}", id))
        },
        Return(ret) => evaluate(vmap, fmap, *ret),
        
        Function(_, args, body) => {
            let closure = make_closure(vmap, fmap, args);
            return evaluate(&closure, fmap, *body);
        },

        If(cond, _true, _false) => {
            if evaluate(vmap, fmap, *cond) == 1 
            {evaluate(vmap, fmap, *_true)} else {evaluate(vmap, fmap, *_false)}
        },
        Call(id, args) => {
            let f = &*fmap.get(&id).expect(&format!("function not found: {}", id));
            let closure = make_closure(vmap, fmap, args);      
            return evaluate(&closure, fmap, (*f).clone());
        }
    }
}

fn main() {
    let f = 
        Function(0x1, 
            vec![
                Box::new(Variable(0x1)), // n
                Box::new(Variable(0x2)), // a
                Box::new(Variable(0x3)), // b
            ],
            Box::new(If(

                Box::new(Equal(
                    Box::new(Variable(0x1)), 
                    Box::new(Number(0)))), // n == 0 ?
                    Box::new(Return(Box::new(Variable(0x2)))), // return a

                    Box::new(If(
                        // cond
                        Box::new(Equal(
                            Box::new(Variable(0x1)),
                            Box::new(Number(1)))), // n == 1 ?
                        // true
                        Box::new(Return(Box::new(Variable(0x3)))), // return b
                        // false
                        Box::new(Return(
                                Box::new(Call(0x1,
                                vec![
                                    Box::new(Sub(
                                        Box::new(Variable(0x1)), 
                                        Box::new(Number(1))) // n - 1
                                    ),
                                    Box::new(Variable(0x3)), // b
                                    Box::new(Add(
                                        Box::new(Variable(0x2)), 
                                        Box::new(Variable(0x3)))), // a + b
                                   ]
                                ))    
                            )),  
                        ))
                    ))
                );
    let fmap: HashMap<i128, Expression> = HashMap::from_iter(vec![(0x1, f)]);
    let vmap: HashMap<i128, i128> = HashMap::new(); // empty
    let expr = Call(0x1, vec![
        Box::new(Number(100)),
        Box::new(Number(0)),
        Box::new(Number(1)),
    ]);
    // println!("result = {}",evaluate(&vmap, &fmap, expr));
    evaluate(&vmap, &fmap, expr);
}