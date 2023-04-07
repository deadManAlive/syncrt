const std = @import("std");
const process = std.process;
const fs = std.fs;
const io = std.io;
const fmt = std.fmt;
const printd = std.debug.print;
const err = std.log.err;
const isSpace = std.ascii.isWhitespace;

//TODO: this
fn secToTime(time: f32) []const u8 {
    _ = time;
    return "hh:mm:ss,sss";
}

fn timeToSec(str: []const u8) !f32 {
    //hours
    var i: usize = 0;
    var end: usize = str.len;

    while (i < end and str[i] != ':') : (i += 1) {}
    // const hours = try fmt.parseInt(i32, str[0..i], 10);
    const hours = try fmt.parseFloat(f32, str[0..i]);

    //minute
    var j = i + 1;
    i += 1;
    while (i < end and str[i] != ':') : (i += 1) {}
    // const minute = try fmt.parseInt(i32, str[j..i], 10);
    const minutes = try fmt.parseFloat(f32, str[j..i]);

    //seconds
    j = i + 1;
    i += 1;
    while (i < end and str[i] != ':') : (i += 1) {}
    const sec_str = str[j..i];

    var alloc = std.heap.page_allocator;
    var dotted = try alloc.alloc(u8, sec_str.len);
    std.mem.copy(u8, dotted, sec_str);
    defer alloc.free(dotted);

    _ = std.mem.replace(u8, sec_str, ",", ".", dotted);

    const seconds = try fmt.parseFloat(f32, dotted);

    return 3600.0 * hours + 60.0 * minutes + seconds;
}

fn trim(str: []const u8) []const u8 {
    var start: usize = 0;
    var end: usize = str.len;

    while (start < end and isSpace(str[start])) : (start += 1) {}

    while (end > start and isSpace(str[end - 1])) : (end -= 1) {}

    return str[start..end];
}

fn parseTime(str: []const u8) !void {
    var i: usize = 0;

    if (str.len < 3) {
        return;
    }

    while (i < str.len - 2) : (i += 1) {
        if (str[i] == '-' and str[i + 1] == '-' and str[i + 2] == '>') {
            var j: usize = 0;

            while (str[j] != '-') : (j += 1) {}

            const start_time = trim(str[0..j]);

            const stop_time = trim(str[(i + 3)..str.len]);

            printd("time(str): [{s}] to [{s}]\n", .{ start_time, stop_time });
            printd("time(sec): {d:.3} to {d:.3}\n", .{ try timeToSec(start_time), try timeToSec(stop_time) });
        }
    }
}

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

    var file_handle = try fs.cwd().openFile(file_name, .{});
    defer file_handle.close();

    var buf_reader = io.bufferedReader(file_handle.reader());
    var in_stream = buf_reader.reader();

    var buffer: [1024]u8 = undefined;
    while (try in_stream.readUntilDelimiterOrEof(&buffer, '\n')) |line| {
        try parseTime(line);
    }

    const nudge = try fmt.parseFloat(f32, args[2]);
    printd("nudge: {d:.3} s\n", .{nudge});
}

test "function test" {
    const time = try timeToSec("00:13:57,013");
    try std.testing.expectApproxEqAbs(time, 837, 1.0);
}
