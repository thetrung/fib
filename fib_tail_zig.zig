fn fib(n: i128, a: i128, b: i128, loop_count: *i128) i128 {
    loop_count.* += 1;
    print("\nn = {} a = {} b = {}", .{ n, a, b });
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
    // _ = fib(93, 0, 1, &loop_count);
    // => 12200160415121876738
    const r = fib(93, 0, 1, &loop_count);
    print("\nacc = {} / loop: {}\n", .{ r, loop_count });
}
