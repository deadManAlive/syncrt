const std = @import("std");
const process = std.process;
const fs = std.fs;
const io = std.io;

pub fn main() !void {
    // ?
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    // ??
    const alloc = arena.allocator();

    // ???
    const args = try process.argsAlloc(alloc);
    defer process.argsFree(alloc, args);

    if (args.len != 2) {
        std.log.err("Usage: <filename>\n", .{});
        return error.InvalidArgs;
    }

    const file_name = args[1];

    std.debug.print("filename: {s}\n", .{file_name});

    var file_handle = try fs.cwd().openFile(file_name, .{});
    defer file_handle.close();

    var buf_reader = io.bufferedReader(file_handle.reader());
    var in_stream = buf_reader.reader();

    var buffer: [1024]u8 = undefined;
    while (try in_stream.readUntilDelimiterOrEof(&buffer, '\n')) |line| {
        std.debug.print("{s}\n", .{line});
    }
}
