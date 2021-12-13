const std = @import("std");
const Interpreter = @import("Interpreter.zig");

const allocator = std.heap.page_allocator;

pub fn main() anyerror!void {
    try interpret("++++++++[>++++[>++>+++>+++>+<<<<-]>+>+>->>+[<]<-]>>.>---.+++++++..+++.>>.<-.<.+++.------.--------.>>+.>++.");
}

fn interpret(src: []const u8) !void {
    var interpreter = Interpreter.init(allocator, src);
    errdefer interpreter.deinit();

    while (interpreter.next()) |operator| {
        switch (operator) {
            '>' => interpreter.increasePtr(),
            '<' => interpreter.decreasePtr(),
            '+' => interpreter.increaseValue(),
            '-' => interpreter.decreaseValue(),
            '[' => try interpreter.startLoop(),
            ']' => interpreter.endLoop(),
            ',' => try interpreter.readChar(),
            '.' => try interpreter.writeChar(),
            else => continue,
        }
    }
}
