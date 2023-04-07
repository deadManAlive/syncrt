const std = @import("std");
const process = std.process;

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    const alloc = arena.allocator();

    const args = try process.argsAlloc(alloc);
    defer process.argsFree(alloc, args);

    if (args.len != 2) {
        std.log.err("Usage: <filename>\n", .{});
        return error.InvalidArgs;
    }

    std.debug.print("filename: {s}\n", .{args[1]});
}
