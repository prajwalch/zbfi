const std = @import("std");

pub const stdin = std.io.getStdIn().reader();
pub const stdout = std.io.getStdOut().writer();
pub const stderr = std.io.getStdErr().writer();
