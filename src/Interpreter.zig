const std = @import("std");
const Self = @This();

const allocator = std.heap.page_allocator;
const stdin = std.io.getStdIn().reader();
const stdout = std.io.getStdOut().writer();

const MEMORY_SIZE = 30_000;

const Loop = struct {
    start_index: usize,
};

src: []const u8,
src_current_index: usize = 0,
src_next_index: usize = 0,

mem: [MEMORY_SIZE]u8 = [_]u8{0} ** MEMORY_SIZE,
mem_index: usize = 0,
loop_stack: std.ArrayList(Loop) = std.ArrayList(Loop).init(allocator),

pub fn init(src: []const u8) Self {
    return Self{ .src = src };
}

pub fn deinit(self: Self) void {
    self.loop_stack.deinit();
}

pub fn next(self: *Self) ?u8 {
    self.src_current_index = self.src_next_index;
    if (self.src_current_index >= self.src.len) return null;
    self.src_next_index += 1;
    return self.src[self.src_current_index];
}

pub fn increasePtr(self: *Self) void {
    if (self.mem_index < self.mem.len) self.mem_index += 1;
}

pub fn decreasePtr(self: *Self) void {
    if (self.mem_index > 0) self.mem_index -= 1;
}

pub fn increaseValue(self: *Self) void {
    self.mem[self.mem_index] += 1;
}

pub fn decreaseValue(self: *Self) void {
    if (self.mem[self.mem_index] > 0)
        self.mem[self.mem_index] -= 1;
}

pub fn startLoop(self: *Self) !void {
    if (self.mem[self.mem_index] == 0) {
        // jump to matching ']' (end of loop)
    } else {
        try self.loop_stack.append(Loop{ .start_index = self.src_current_index });
    }
}

pub fn endLoop(self: *Self) void {
    const last_loop_stack = self.loop_stack.popOrNull() orelse {
        std.debug.print("found loop ] without matching [ at index {d}\n", .{self.src_current_index});
        std.process.exit(1);
    };

    // if current value is 0 it will automatically jump
    // to next instruction using 'src_next_index'
    if (self.mem[self.mem_index] != 0) {
        // jump to matching '[' (start of loop)
        self.src_next_index = last_loop_stack.start_index;
    }
}

pub fn readChar(self: *Self) !void {
    var char = try stdin.readByte();
    try stdin.skipUntilDelimiterOrEof('\n');
    self.mem[self.mem_index] = char;
}
