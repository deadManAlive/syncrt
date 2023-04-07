const std = @import("std");
const fmt = std.fmt;
const printd = std.debug.print;
const isSpace = std.ascii.isWhitespace;

pub const Range = struct {
    start: f32,
    end: f32,
};

//TODO: this
pub fn secToTime(time: f32) []const u8 {
    _ = time;
    return "hh:mm:ss,sss";
}

pub fn timeToSec(str: []const u8) anyerror!f32 {
    //hours
    var i: usize = 0;
    var end: usize = str.len;

    while (i < end and str[i] != ':') : (i += 1) {}
    const hours = try fmt.parseFloat(f32, str[0..i]);

    //minute
    var j = i + 1;
    i += 1;
    while (i < end and str[i] != ':') : (i += 1) {}
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

pub fn trim(str: []const u8) []const u8 {
    var start: usize = 0;
    var end: usize = str.len;

    while (start < end and isSpace(str[start])) : (start += 1) {}

    while (end > start and isSpace(str[end - 1])) : (end -= 1) {}

    return str[start..end];
}

pub fn parseTime(str: []const u8) ?Range {
    var i: usize = 0;

    if (str.len < 3) {
        return null;
    }

    while (i < str.len - 2) : (i += 1) {
        if (str[i] == '-' and str[i + 1] == '-' and str[i + 2] == '>') {
            var j: usize = 0;

            while (str[j] != '-') : (j += 1) {}

            const start_time = trim(str[0..j]);
            const end_time = trim(str[(i + 3)..str.len]);

            var start: f32 = undefined;
            var end: f32 = undefined;

            if (timeToSec(start_time)) |time| {
                start = time;
            } else |_| {
                return null;
            }

            if (timeToSec(end_time)) |time| {
                end = time;
            } else |_| {
                return null;
            }

            printd("time(str): [{s}] to [{s}]\n", .{ start_time, end_time });

            return Range{ .start = start, .end = end };
        }
    }

    return null;
}
