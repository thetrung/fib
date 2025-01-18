define i128 @addi128(i128 %a, i128 %b){
    %low_a = trunc i128 %a to i64
    %low_b = trunc i128 %b to i64
    %low_sum = add i64 %low_a, %low_b
    %low_carry = icmp ugt i64 %low_sum, %low_a
    %i64_low_carry = zext i1 %low_carry to i64

    %high_a = lshr i128 %a, 64                      ; Logical Shift Right by 64
    %high_b = lshr i128 %b, 64
    %i64_high_a = trunc i128 %high_a to i64
    %i64_high_b = trunc i128 %high_b to i64
    %high_sum = add i64  %i64_high_a, %i64_high_b
    %high_result = add i64 %high_sum, %i64_low_carry


    %low_ex = zext i64 %low_sum to i128
    %high_ex = zext i64 %high_result to i128

    %high_shifted = shl i128 %high_ex, 64    ; Logical Shift Left by 64 
    %result = or i128 %low_ex, %high_shifted
    ret i128 %result
}

define i128 @fib(i128 %n, i128 %a, i128 %b, i128* %count) {
    entry:
        ; Update count
        %count_val = load i128, i128* %count
        %next_count = add i128 %count_val, 1
        store i128 %next_count, i128* %count

        ; Check if n == 0
        %is_n_zero = icmp eq i128 %n, 0
        br i1 %is_n_zero, label %return_a, label %check_n_one

    check_n_one:
        ; Check if n == 1
        %n_eq_1 = icmp eq i128 %n, 1
        br i1 %n_eq_1, label %return_b, label %recurse

    recurse:
        ; Update next/result
        %next_n = sub i128 %n, 1
        %next_a = add i128 0, %b
        %next_b = call i128 @addi128(i128 %a, i128 %b)

        ; Tail call with updated count and correct passing
        %tail_call = call i128 @fib(i128 %next_n, i128 %next_a, i128 %next_b, i128* %count)
        ret i128 %tail_call

    return_a:
        ret i128 %a
    
    return_b:
        ret i128 %b
}


declare i32 @printf(i8*, ...)
@format = private constant [29 x i8] c"fib: %llu %llu, Count: %d\0a\0n"

define i32 @main(){
    %count = alloca i128
    store i128 0, i128* %count

    ; Call fib
    %final_result = call i128 @fib(i128 94, i128 0, i128 1, i128* %count)
    
    ; Convert lower 64 bits of i128 to i64
    %final_count = load i128, i128* %count
    %low_bits_count = trunc i128 %final_count to i32

    ; Convert 128-bit result -> 2x 64-bit chunks :
    %low_i64 = trunc i128 %final_result to i64
    %shift_64 = lshr i128 %final_result, 64
    %high_i64 = trunc i128 %shift_64 to i64

    ; Call Printf
    %format_ptr = getelementptr [29 x i8], [29 x i8]* @format, i32 0, i32 0
    call i32 (i8*, ...) @printf(i8* %format_ptr, i64 %high_i64, i64 %low_i64, i32 %low_bits_count)

    ret i32 0
}