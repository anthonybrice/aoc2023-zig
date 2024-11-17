const d3p1 = @import("d3p1.zig");
const std = @import("std");

pub fn main() !void {
    var in = try std.fs.cwd().openFile("in/d3p1", .{ .mode = .read_only });
    defer in.close();

    var allocator = std.heap.page_allocator;
    const file_contents = try in.readToEndAlloc(allocator, std.math.maxInt(usize));
    defer allocator.free(file_contents);

    const lines = try d3p1.parseInto2DArray(allocator, file_contents);
    defer lines.deinit();

    var sum: i32 = 0;

    for (lines.items, 0..lines.items.len) |line, rowNum| {
        for (line, 0..line.len) |c, i| {
            if (c == '*') sum += parseGearNumber(lines, rowNum, i);
        }
    }
}

fn parseGearNumber(lines: [][]u8, row_idx: i32, col_idx: i32) i32 {
    _ = lines;
    _ = row_idx;
    _ = col_idx;

    return 0;
}
