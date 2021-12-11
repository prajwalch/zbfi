const std = @import("std");
const Self = @This();

const allocator = std.heap.page_allocator;

src: []const u8,
ptr: usize = 0,
src_idx: usize = 0,
src_mem: [30_000]usize = [_]usize{0} ** 30_000,
/// when ptr will be at ']' then -1 indicates
/// that there is no any looo start operator
loop_start_idx: usize = 0,

pub fn init(src: []const u8) Self {
    return Self{ .src = src };
}

pub fn next(self: *Self) ?u8 {
    if (self.src_idx >= self.src.len) return null;
    const ch = self.src[self.src_idx];
    self.src_idx += 1;
    return ch;
}

pub fn increasePtr(self: *Self) void {
    if (self.ptr < self.src_mem.len) self.ptr += 1;
}

pub fn decreasePtr(self: *Self) void {
    if (self.ptr > 0) self.ptr -= 1;
}

pub fn increaseValue(self: *Self) void {
    self.src_mem[self.ptr] += 1;
}

pub fn decreaseValue(self: *Self) void {
    if (self.src_mem[self.ptr] > 0)
        self.src_mem[self.ptr] -= 1;
}

pub fn startLoop(self: *Self) void {
    if (self.src_mem[self.ptr] == 0) {
        // jump to matching ']'
    } else {
        self.loop_start_idx = self.src_idx;
    }
}

pub fn endLoop(self: *Self) void {
    if (self.loop_start_idx == 0) {
        std.debug.print("missing loop ] at idx: {d}\n", .{self.src_idx});
        std.process.exit(1);
    }

    if (self.src_mem[self.ptr] == 0) {
        self.src_idx += 1;
    } else {
        // jump to matching '[' (start of loop)
        self.src_idx = self.loop_start_idx;
    }
}
