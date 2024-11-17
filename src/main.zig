const std = @import("std");

pub fn main() !void {
    var in = try std.fs.cwd().openFile("in/d3p1", .{ .mode = .read_only });
    defer in.close();

    var allocator = std.heap.page_allocator;
    const fileContents = try in.readToEndAlloc(allocator, std.math.maxInt(usize));
    defer allocator.free(fileContents);

    const lines = try parseInto2DArray(allocator, fileContents);
    defer lines.deinit();

    var sum: i32 = 0;
    for (lines.items, 0..lines.items.len) |line, row_index| {
        for (line, 0..line.len) |char, colIndex| {
            if (std.ascii.isDigit(char)) {
                const number = char - '0';
                if (checkAdjacentForAsterisk(lines.items, row_index, colIndex)) {
                    sum += number;
                }
            }
        }
    }

    for (lines.items) |line| {
        std.debug.print("{s}\n", .{line});
    }
}

fn parseInto2DArray(allocator: std.mem.Allocator, fileContents: []u8) !std.ArrayList([]u8) {
    var lines = std.ArrayList([]u8).init(allocator);

    var it = std.mem.split(u8, fileContents, "\n");
    while (it.next()) |line| {
        const lineCopy = try allocator.alloc(u8, line.len);
        std.mem.copyForwards(u8, lineCopy, line);
        try lines.append(lineCopy);
    }

    return lines;
}

fn checkAdjacentForAsterisk(lines: [][]u8, rowIndex: usize, colIndex: usize) bool {
    const directions = [_][2]i32{
        .{ -1, 0 }, // above
        .{ 1, 0 }, // below
        .{ 0, -1 }, // left
        .{ 0, 1 }, // right
    };

    for (directions) |dir| {
        const newRow = rowIndex + dir[0];
        const newCol = colIndex + dir[1];
        if (newRow >= 0 and newRow < lines.len and newCol >= 0 and newCol < lines[newRow].len) {
            if (lines[newRow][newCol] == '*') {
                return true;
            }
        }
    }

    return false;
}

test "simple test" {
    var list = std.ArrayList(i32).init(std.testing.allocator);
    defer list.deinit(); // try commenting this out and see if zig detects the memory leak!
    try list.append(42);
    try std.testing.expectEqual(@as(i32, 42), list.pop());
}
