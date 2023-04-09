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
    const stdout_file = std.io.getStdOut().writer();
    var bw = std.io.bufferedWriter(stdout_file);
    const stdout = bw.writer();

    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    const alloc = arena.allocator();

    const args = try process.argsAlloc(alloc);
    defer process.argsFree(alloc, args);

    if (args.len != 3) {
        err("Usage: <filename> <nudge (in signed seconds OR current-target)>\n", .{});
        return error.InvalidArgs;
    }

    const file_name = args[1];

    var shift: f32 = undefined;

    if (fmt.parseFloat(f32, args[2])) |val| {
        shift = val;
    } else |_| {
        if (parse.rangeToSec(args[2])) |val| {
            shift = val;
        } else {
            err("Usage: <filename> <nudge (in signed seconds OR current-target)>\n", .{});
            return error.InvalidArgs;
        }
    }

    // try stdout.print("shift: {d:.3}\n", .{shift});

    var file_handle = try fs.cwd().openFile(file_name, .{});
    defer file_handle.close();

    var buf_reader = io.bufferedReader(file_handle.reader());
    var in_stream = buf_reader.reader();

    var buffer: [1024]u8 = undefined;
    while (try in_stream.readUntilDelimiterOrEof(&buffer, '\n')) |line| {
        if (parseTime(line)) |*range| {
            var r = range.*; // but why??

            try r.nudge(shift); // ??

            var timebuff: [128]u8 = undefined;
            var fba = std.heap.FixedBufferAllocator.init(&timebuff);
            const allocator = fba.allocator();
            const new_start = try parse.secToTime(allocator, r.start);
            const new_end = try parse.secToTime(allocator, r.end);

            try stdout.print("{s} --> {s}\n", .{ new_start, new_end });
        } else {
            try stdout.print("{s}\n", .{line});
        }
    }

    try bw.flush();
}

test "time to sec" {
    const time = try parse.timeToSec("00:13:57,013");
    try std.testing.expectApproxEqAbs(time, 837, 1.0);
}

test "time to sec point" {
    const time = try parse.timeToSec("00:13:57.013");
    try std.testing.expectApproxEqAbs(time, 837, 1.0);
}

test "time to sec arbitrary" {
    const time = try parse.timeToSec("00:13:57");
    try std.testing.expectApproxEqAbs(time, 837, 1.0);
}

test "shift" {
    const shift = parse.rangeToSec("00:10:00-00:11:00") orelse 0.0;
    try std.testing.expectApproxEqAbs(shift, 60, 1.0);
}

test "sec to time" {
    var buff: [128]u8 = undefined;
    var fba = std.heap.FixedBufferAllocator.init(&buff);
    const alloc = fba.allocator();
    const result = try parse.secToTime(alloc, 837.0);
    try std.testing.expect(std.mem.eql(u8, result, "00:13:57,000"));
}
