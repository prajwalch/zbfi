const std = @import("std");
const Interpreter = @import("Interpreter.zig");

const allocator = std.heap.page_allocator;

pub fn main() anyerror!void {
    _ = Interpreter.interpret(allocator, "+++++>>++++++++++++<<[>,.>.<<-");
}
