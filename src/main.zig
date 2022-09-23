const std = @import("std");
const Interpreter = @import("Interpreter.zig");
const utils = @import("utils.zig");
const yazap = @import("yazap");

const pga = std.heap.page_allocator;
const flag = yazap.flag;
const Command = yazap.Command;
const Yazap = yazap.Yazap;

pub fn main() anyerror!void {
    var zbfi = try initCliArgs(pga);
    defer zbfi.deinit();

    var args = try zbfi.parseProcess();

    if (args.valueOf("file")) |file_name| {
        var src = readSrcFile(pga, file_name) catch |err| switch (err) {
            error.InvalidFileFormat => {
                std.debug.print("Error: Invalid file format\n", .{});
                std.process.exit(1);
            },
            error.FileNotFound => {
                std.debug.print("Error: Src file not found\n", .{});
                std.process.exit(1);
            },
            else => |e| return e,
        };
        _ = Interpreter.interpret(pga, src);
        return;
    }

    try runInteractiveMode(pga);
}

fn initCliArgs(allocator: std.mem.Allocator) !Yazap {
    var app = Yazap.init(allocator, "zbfi", "BrainFuck Interpreter written in zig");
    errdefer app.deinit();

    try app.rootCommand().addArg(flag.argOne("file", 'f', "Source file to interpret"));
    return app;
}

fn readSrcFile(allocator: std.mem.Allocator, file_path: []const u8) ![]u8 {
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

fn runInteractiveMode(allocator: std.mem.Allocator) !void {
    std.debug.print(
        \\ ███████╗██████╗░███████╗██╗
        \\ ╚════██║██╔══██╗██╔════╝██║
        \\ ░░███╔═╝██████╦╝█████╗░░██║
        \\ ██╔══╝░░██╔══██╗██╔══╝░░██║
        \\ ███████╗██████╦╝██║░░░░░██║
        \\ ╚══════╝╚═════╝░╚═╝░░░░░╚═╝
        \\
        \\ Welcome to Zbfi REPL mode
        \\ Run ;quit to close REPL mode
        \\
    , .{});
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
