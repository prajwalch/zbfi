const std = @import("std");
const Self = @This();

const allocator = std.heap.page_allocator;
const stdin = std.io.getStdIn().reader();
const stdout = std.io.getStdOut().writer();

const MEMORY_SIZE = 30_000;

src: []const u8,
src_current_index: usize = 0,
src_next_index: usize = 0,

mem: [MEMORY_SIZE]u8 = [_]u8{0} ** MEMORY_SIZE,
mem_index: usize = 0,
loop_stack: std.ArrayList(usize) = std.ArrayList(usize).init(allocator),

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
    const loop_end_index = self.findEndOfLoop() orelse {
        std.debug.print("syntax error: found unmatched ']' of index {d}\n ", .{self.src_current_index});
        std.process.exit(1);
    };

    if (self.mem[self.mem_index] == 0) {
        // jump to matching ']' (end of loop)
        self.src_next_index = loop_end_index + 1;
    } else {
        try self.loop_stack.append(self.src_current_index);
    }
}

pub fn endLoop(self: *Self) void {
    const loop_start_index = self.loop_stack.popOrNull() orelse {
        std.debug.print("syntax error: found unmatched '[' of index {d}\n", .{self.src_current_index});
        std.process.exit(1);
    };

    // Here no need to check wether current value is zero or not
    // because it will jump to next instruction anyway using 'src_next_index'
    if (self.mem[self.mem_index] != 0) {
        // jump to matching '[' (start of loop)
        self.src_next_index = loop_start_index;
    }
}

pub fn readChar(self: *Self) !void {
    var char = try stdin.readByte();
    try stdin.skipUntilDelimiterOrEof('\n');
    self.mem[self.mem_index] = char;
}

pub fn writeChar(self: *Self) !void {
    try stdout.writeByte(self.mem[self.mem_index]);
}

fn findEndOfLoop(self: *Self) ?usize {
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
                return self.src_current_index - 1;
            }
        }
    }
    return null;
}
