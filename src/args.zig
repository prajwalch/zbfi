const std = @import("std");
const clap = @import("clap");
const utils = @import("utils.zig");

const Args = struct {
    is_help: bool = false,
    src_file: ?[]const u8 = null,
    // mem_size: usize,
};

pub fn parse() !Args {
    var zbfi_args = Args{};

    const params = comptime [_]clap.Param(clap.Help){
        clap.parseParam("-h, --help             Display help") catch unreachable,
        clap.parseParam("-f, --file <STR>       Source file to interpret") catch unreachable,
    };

    var args = try clap.parse(clap.Help, &params, .{});
    defer args.deinit();

    if (args.flag("--help")) {
        try clap.help(utils.stdout, &params);
        zbfi_args.is_help = true;
        return zbfi_args;
    }
    if (args.option("--file")) |src_file| {
        zbfi_args.src_file = src_file;
        return zbfi_args;
    }
    return zbfi_args;
}
