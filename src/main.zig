const std = @import("std");
const process = std.process;
const fs = std.fs;
const io = std.io;
const fmt = std.fmt;
const printd = std.debug.print;
const err = std.log.err;

const parse = @import("parse.zig");
const parseTime = parse.parseTime;

pub fn main() !void {
    // ?
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    // ??
    const alloc = arena.allocator();

    // ???
    const args = try process.argsAlloc(alloc);
    defer process.argsFree(alloc, args);

    if (args.len != 3) {
        err("Usage: <filename> <nudge (in signed seconds)>\n", .{});
        return error.InvalidArgs;
    }

    const file_name = args[1];

    printd("filename: {s}\n", .{file_name});

    const nudge = try fmt.parseFloat(f32, args[2]);
    printd("nudge: {d:.3} s\n", .{nudge});

    var file_handle = try fs.cwd().openFile(file_name, .{});
    defer file_handle.close();

    var buf_reader = io.bufferedReader(file_handle.reader());
    var in_stream = buf_reader.reader();

    var buffer: [1024]u8 = undefined;
    while (try in_stream.readUntilDelimiterOrEof(&buffer, '\n')) |line| {
        if (parseTime(line)) |range| {
            printd("time(sec): {d:.3} to {d:.3}\n", .{ range.start, range.end });

            const new_start = range.start + nudge;
            const new_end = range.end + nudge;

            if (new_start < 0.0) {
                return error.InvalidTime;
            }

            printd("new (sec): {d:.3} to {d:.3}\n", .{ new_start, new_end });
        }
    }
}

test "function test" {
    const time = try parse.timeToSec("00:13:57,013");
    try std.testing.expectApproxEqAbs(time, 837, 1.0);
}
