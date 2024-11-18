const std = @import("std");
const d3p1 = @import("day3/part1.zig");
const d3p2 = @import("day3/part2.zig");
const d4p1 = @import("day4/part1.zig");
const d4p2 = @import("day4/part2.zig");

pub fn main() !void {
    const allocator = std.heap.page_allocator;
    var args = try std.process.argsWithAllocator(allocator);
    defer args.deinit();

    _ = args.next(); // Skip the program name.
    const part = args.next().?;
    const input_file = args.next().?;

    const case = std.meta.stringToEnum(Case, part);
    if (case == null) {
        return std.debug.print("Invalid part: {s}\n", .{part});
    }

    switch (case.?) {
        .d3p1 => try d3p1.main(input_file),
        .d3p2 => try d3p2.main(input_file),
        .d4p1 => try d4p1.main(input_file),
        .d4p2 => try d4p2.main(input_file),
    }
}

const Case = enum {
    d3p1,
    d3p2,
    d4p1,
    d4p2,
};
