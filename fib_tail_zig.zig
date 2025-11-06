fn fib(n: i128, a: i128, b: i128, loop_count: *i128) i128 {
    loop_count.* += 1;
    // print("\nn = {} a = {} b = {}", .{ n, a, b });
    switch (n) {
        0 => return a,
        1 => return b,
        else => {
            return fib(n - 1, b, a + b, loop_count);
        },
    }
}

const std = @import("std");
const print = std.debug.print;

pub fn main() !void {
    var loop_count: i128 = 0;
    _ = fib(90, 0, 1, &loop_count);
    // Fib(90) => 2880067194370816120 | loop 180
    // const r = fib(90, 0, 1, &loop_count);
    // print("\nacc = {} / loop: {}\n", .{ r, loop_count });
}
