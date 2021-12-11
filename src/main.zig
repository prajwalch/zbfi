const std = @import("std");
const Interpreter = @import("Interpreter.zig");

pub fn main() anyerror!void {
    interpret(">>>++++[].");
}

fn interpret(src: []const u8) void {
    var interpreter = Interpreter.init(src);

    while (interpreter.next()) |operator| {
        switch (operator) {
            '>' => interpreter.increasePtr(),
            '<' => interpreter.decreasePtr(),
            '+' => interpreter.increaseValue(),
            '-' => interpreter.decreaseValue(),
            '[' => interpreter.startLoop(),
            ']' => interpreter.endLoop(),
            //',' => interpreter.getChar(),
            //'.' => interpreter.putChar(),
            else => {
                std.debug.print("Unknown indentifier\n", .{});
            },
        }
    }
}
