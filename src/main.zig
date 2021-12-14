const std = @import("std");
const Interpreter = @import("Interpreter.zig");
const utils = @import("utils.zig");
const args = @import("args.zig");

const allocator = std.heap.page_allocator;

pub fn main() anyerror!void {
    const zbfi_args = args.parse() catch |err| switch (err) {
        error.MissingValue => {
            std.debug.warn("Error: Missing value\n", .{});
            return;
        },
        else => |e| return e,
    };

    if (zbfi_args.is_help) {
        return;
    }

    if (zbfi_args.src_file) |file_path| {
        std.debug.print("Read source file\n", .{});
        return;
    }

    while (true) {
        std.debug.print("> ", .{});

        var src_input = try utils.stdin.readUntilDelimiterOrEofAlloc(allocator, '\n', 1024);
        if (src_input) |src| {
            if (std.mem.eql(u8, src, ";quit")) {
                break;
            }
            _ = Interpreter.interpret(allocator, src);
            std.debug.print("\n", .{});
        }
    }
    std.debug.print("[Interpreter Ended]\n", .{});
}
