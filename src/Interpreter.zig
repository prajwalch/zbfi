const Interpreter = @This();

const std = @import("std");
const utils = @import("utils.zig");

const MEMORY_SIZE = 30_000;
const SyntaxError = error{
    OpenBracketNotFound,
    CloseBracketNotFound,
};

src: []const u8,
src_current_index: usize = 0,
src_next_index: usize = 0,

mem: [MEMORY_SIZE]u8 = [_]u8{0} ** MEMORY_SIZE,
mem_index: usize = 0,
loop_stack: std.ArrayList(usize),

pub fn interpret(allocator: std.mem.Allocator, src: []const u8) bool {
    var interpreter = Interpreter.init(allocator, src);
    defer interpreter.deinit();

    while (interpreter.nextCommand()) |cmd| {
        switch (cmd) {
            '>' => interpreter.increasePtr(),
            '<' => interpreter.decreasePtr(),
            '+' => interpreter.increaseValue(),
            '-' => interpreter.decreaseValue(),
            '[' => {
                interpreter.startLoop() catch |err| switch (err) {
                    error.CloseBracketNotFound => {
                        std.debug.print("Syntax Error: matching ']' not found at index '{d}'\n", .{interpreter.src_current_index + 1});
                        return false;
                    },
                    else => {
                        std.debug.print("Interpreter error: some error occured while creating loop stack\n", .{});
                        return false;
                    },
                };
            },
            ']' => {
                interpreter.endLoop() catch |err| switch (err) {
                    error.OpenBracketNotFound => {
                        std.debug.print("Syntax Error: matching '[' not found at index '{d}'\n", .{interpreter.src_current_index + 1});
                        return false;
                    },
                    else => continue,
                };
            },
            ',' => {
                interpreter.readChar() catch |e| {
                    std.debug.print("Error: failed to read byte from stdin {s}\n", .{e});
                    return false;
                };
            },
            '.' => {
                interpreter.writeChar() catch |e| {
                    std.debug.print("Error: failed to prnt byte on stdin {s}\n", .{e});
                    return false;
                };
            },
            else => continue,
        }
    }
    return true;
}

pub fn init(allocator: std.mem.Allocator, src: []const u8) Interpreter {
    return Interpreter{
        .src = src,
        .loop_stack = std.ArrayList(usize).init(allocator),
    };
}

pub fn deinit(self: Interpreter) void {
    self.loop_stack.deinit();
}

pub fn nextCommand(self: *Interpreter) ?u8 {
    if (self.src_next_index >= self.src.len) return null;

    self.src_current_index = self.src_next_index;
    self.src_next_index += 1;
    return self.src[self.src_current_index];
}

pub fn increasePtr(self: *Interpreter) void {
    if (self.mem_index < self.mem.len) self.mem_index += 1;
}

pub fn decreasePtr(self: *Interpreter) void {
    if (self.mem_index > 0) self.mem_index -= 1;
}

pub fn increaseValue(self: *Interpreter) void {
    self.mem[self.mem_index] +%= 1;
}

pub fn decreaseValue(self: *Interpreter) void {
    self.mem[self.mem_index] -%= 1;
}

pub fn startLoop(self: *Interpreter) !void {
    const loop_end_index = self.findEndOfLoop() orelse {
        return SyntaxError.CloseBracketNotFound;
    };

    if (self.mem[self.mem_index] == 0) {
        // jump to matching ']' (end of loop)
        self.src_next_index = loop_end_index + 1;
    } else {
        try self.loop_stack.append(self.src_current_index);
    }
}

pub fn endLoop(self: *Interpreter) !void {
    const loop_start_index = self.loop_stack.popOrNull() orelse {
        return SyntaxError.OpenBracketNotFound;
    };

    // Here no need to check wether current value is zero or not
    // because it will jump to next instruction anyway using 'src_next_index'
    if (self.mem[self.mem_index] != 0) {
        // jump to matching '[' (start of loop)
        self.src_next_index = loop_start_index;
    }
}

pub fn readChar(self: *Interpreter) !void {
    var char = try utils.stdin.readByte();
    try utils.stdin.skipUntilDelimiterOrEof('\n');
    self.mem[self.mem_index] = char;
}

pub fn writeChar(self: *Interpreter) !void {
    try utils.stdout.writeByte(self.mem[self.mem_index]);
}

fn findEndOfLoop(self: *Interpreter) ?usize {
    var nums_open_bracket: usize = 0;
    var nums_close_bracket: usize = 0;

    var src_slice = self.src[self.src_current_index..];
    for (src_slice) |c, i| {
        if (c == '[') {
            nums_open_bracket += 1;
        } else if (c == ']') {
            nums_close_bracket += 1;
        }

        if (nums_open_bracket > 0) {
            if (nums_open_bracket == nums_close_bracket) {
                return self.src_current_index + i;
            }
        }
    }
    return null;
}
