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

    var sum: u32 = 0;

    for (lines.items, 0..lines.items.len) |line, row_idx| {
        for (line, 0..line.len) |c, col_idx| {
            if (c == '*')
                sum += parseGearNumber(allocator, lines.items, row_idx, col_idx);
        }
    }

    std.debug.print("{d}\n", .{sum});
}

fn parseGearNumber(allocator: std.mem.Allocator, lines: [][]u8, row_idx: usize, col_idx: usize) u32 {
    var adj_nums = std.ArrayList(u32).init(allocator);
    defer adj_nums.deinit();

    // collect above numbers
    if (row_idx > 0) {
        const adj_above = adjacentNums(
            allocator,
            lines,
            row_idx - 1,
            col_idx,
            isAdjacentAboveOrBelow,
        );
        defer adj_above.deinit();
        for (adj_above.items) |num| adj_nums.append(num) catch unreachable;
    }

    // collect left numbers
    if (col_idx != 0) {
        const adj_left = adjacentNums(
            allocator,
            lines,
            row_idx,
            col_idx,
            isLeftAdjacent,
        );
        defer adj_left.deinit();
        for (adj_left.items) |num| adj_nums.append(num) catch unreachable;
    }

    // collect right numbers
    if (col_idx != lines[row_idx].len - 1) {
        const adj_right = adjacentNums(
            allocator,
            lines,
            row_idx,
            col_idx,
            isRightAdjacent,
        );
        defer adj_right.deinit();
        for (adj_right.items) |num| adj_nums.append(num) catch unreachable;
    }

    // collect below numbers
    if (row_idx != lines.len - 2) {
        const adj_below = adjacentNums(
            allocator,
            lines,
            row_idx + 1,
            col_idx,
            isAdjacentAboveOrBelow,
        );
        defer adj_below.deinit();
        for (adj_below.items) |num| adj_nums.append(num) catch unreachable;
    }

    if (adj_nums.items.len == 2) return adj_nums.items[0] * adj_nums.items[1];

    return 0;
}

fn adjacentNums(
    allocator: std.mem.Allocator,
    lines: [][]u8,
    row_idx: usize,
    col_idx: usize,
    pred: fn (std.mem.Allocator, usize, usize, usize) bool,
) std.ArrayList(u32) {
    const line = lines[row_idx];
    var buffer: [10]u8 = undefined;
    var buf_idx: u32 = 0;
    var adj_nums = std.ArrayList(u32).init(allocator);

    for (line, 0..line.len) |c, idx| {
        if (std.ascii.isDigit(c) and buf_idx < buffer.len) {
            buffer[buf_idx] = c;
            buf_idx += 1;
        } else if (buf_idx > 0) {
            const digit_slice = buffer[0..buf_idx];
            const value = std.fmt.parseInt(u32, digit_slice, 10) catch unreachable;
            if (pred(allocator, idx - @as(usize, countDigits(@intCast(value))), idx, col_idx))
                adj_nums.append(value) catch unreachable;

            buf_idx = 0;
        }
    }

    if (buf_idx > 0) {
        const digit_slice = buffer[0..buf_idx];
        const value = std.fmt.parseInt(u32, digit_slice, 10) catch unreachable;
        if (pred(allocator, line.len - @as(usize, countDigits(@intCast(value))), line.len, col_idx))
            adj_nums.append(value) catch unreachable;

        buf_idx = 0;
    }

    return adj_nums;
}

pub fn countDigits(n: u32) u32 {
    var abs_n = if (n < 0) -n else n;
    if (abs_n == 0) return 1;

    var count: u32 = 0;
    while (abs_n != 0) {
        abs_n = @divFloor(abs_n, 10);
        count += 1;
    }
    return count;
}

fn isAdjacentAboveOrBelow(allocator: std.mem.Allocator, start_idx: usize, end_idx: usize, ast_idx: usize) bool {
    const adj_idxs = [_]usize{ ast_idx - 1, ast_idx, ast_idx + 1 };
    const num_idxs = createRange(allocator, start_idx, end_idx) catch unreachable;
    defer allocator.free(num_idxs);

    for (adj_idxs) |adj_idx|
        if (arrayContains(usize, num_idxs, adj_idx))
            return true;

    return false;
}

fn isLeftAdjacent(_: std.mem.Allocator, _: usize, end_idx: usize, ast_idx: usize) bool {
    return end_idx == ast_idx;
}

fn isRightAdjacent(_: std.mem.Allocator, start_idx: usize, _: usize, ast_idx: usize) bool {
    return start_idx == ast_idx + 1;
}

fn createRange(allocator: std.mem.Allocator, start_idx: usize, end_idx: usize) ![]usize {
    const size = end_idx - start_idx;
    const range = try allocator.alloc(usize, size);

    for (range, 0..size) |*item, i| {
        item.* = start_idx + i;
    }

    return range;
}

fn arrayContains(comptime T: type, haystack: []T, needle: T) bool {
    for (haystack) |element|
        if (element == needle)
            return true;
    return false;
}
