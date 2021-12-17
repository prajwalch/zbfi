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
        var content = readSrcFile(file_path) catch |err| switch (err) {
            error.InvalidFileFormat => {
                std.debug.warn("Error: Invalid File Format\n", .{});
                std.process.exit(1);
            },
            error.FileNotFound => {
                std.debug.warn("Error: File not found\n", .{});
                std.process.exit(1);
            },
            else => |e| return e,
        };
        defer allocator.free(content);

        _ = Interpreter.interpret(allocator, content);
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

fn readSrcFile(file_path: []const u8) ![]u8 {
    if (!isValidExtension(file_path))
        return error.InvalidFileFormat;

    var file = try std.fs.cwd().openFile(file_path, .{ .read = true });
    defer file.close();
    var content = try file.reader().readAllAlloc(allocator, 1024);
    return content;
}

fn isValidExtension(file_path: []const u8) bool {
    const file_ext = std.fs.path.extension(file_path);
    if (!std.mem.eql(u8, file_ext, ".b") and !std.mem.eql(u8, file_ext, ".bf"))
        return false;
    return true;
}
