const std = @import("std");

pub fn parseInto2DArray(allocator: std.mem.Allocator, fileContents: []u8) !std.ArrayList([]u8) {
    var lines = std.ArrayList([]u8).init(allocator);

    var it = std.mem.split(u8, fileContents, "\n");
    while (it.next()) |line| {
        const lineCopy = try allocator.alloc(u8, line.len);
        std.mem.copyForwards(u8, lineCopy, line);
        try lines.append(lineCopy);
    }

    return lines;
}

pub fn arrayContains(comptime T: type, haystack: []T, needle: T) bool {
    for (haystack) |element|
        if (element == needle)
            return true;
    return false;
}
