const std = @import("std");

pub fn main() !void {
    var in = try std.fs.cwd().openFile("in/d3p1", .{ .mode = .read_only });
    defer in.close();

    var allocator = std.heap.page_allocator;
    const file_contents = try in.readToEndAlloc(allocator, std.math.maxInt(usize));
    defer allocator.free(file_contents);

    const lines = try parseInto2DArray(allocator, file_contents);
    defer lines.deinit();

    var sum: i32 = 0;
    for (lines.items, 0..lines.items.len) |line, row_idx| {
        var buffer: [10]u8 = undefined;
        var buf_idx: u32 = 0;

        for (line, 0..line.len) |c, col_idx| {
            if (std.ascii.isDigit(c) and buf_idx < buffer.len) {
                buffer[buf_idx] = c;
                buf_idx += 1;
            } else if (buf_idx > 0) {
                const digit_slice = buffer[0..buf_idx];
                const value = try std.fmt.parseInt(i32, digit_slice, 10);
                if (isPartNumber(allocator, value, @intCast(col_idx), lines.items, @intCast(row_idx)))
                    sum += value;
                buf_idx = 0;
            }
        }

        if (buf_idx > 0) {
            const digit_slice = buffer[0..buf_idx];
            const value = try std.fmt.parseInt(i32, digit_slice, 10);
            if (isPartNumber(allocator, value, @intCast(line.len), lines.items, @intCast(row_idx)))
                sum += value;
            buf_idx = 0;
        }
    }

    std.debug.print("{d}\n", .{sum});
}

fn isPartNumber(allocator: std.mem.Allocator, val: i32, col_idx: i32, lines: [][]u8, row_idx: i32) bool {
    var adj_chars = std.ArrayList(u8).init(allocator);
    defer adj_chars.deinit();

    const num_digits = countDigits(val);

    // collect above symbols
    if (row_idx > 0) {
        const above_row = lines[@intCast(row_idx - 1)];
        const start_idx = if (col_idx - num_digits <= 0) 0 else col_idx - num_digits - 1;
        const end_idx = if (col_idx == above_row.len) col_idx else col_idx + 1;
        adj_chars.appendSlice(above_row[@intCast(start_idx)..@intCast(end_idx)]) catch unreachable;
    }

    // collect left and right symbols
    if (col_idx - num_digits != 0) adj_chars.append(lines[@intCast(row_idx)][@intCast(col_idx - num_digits - 1)]) catch unreachable;
    if (col_idx != lines[@intCast(row_idx)].len) adj_chars.append(lines[@intCast(row_idx)][@intCast(col_idx)]) catch unreachable;

    // collect below symbols
    if (row_idx != lines.len - 2) {
        const below_row = lines[@intCast(row_idx + 1)];
        const start_idx = if (col_idx - num_digits <= 0) 0 else col_idx - num_digits - 1;
        const end_idx = if (col_idx == below_row.len) col_idx else col_idx + 1;
        adj_chars.appendSlice(below_row[@intCast(start_idx)..@intCast(end_idx)]) catch unreachable;
    }

    for (adj_chars.items) |c| {
        if (c != '.' and !std.ascii.isDigit(c)) {
            return true;
        }
    }
    return false;
}

pub fn countDigits(n: i32) i32 {
    var abs_n = if (n < 0) -n else n;
    if (abs_n == 0) return 1;

    var count: i32 = 0;
    while (abs_n != 0) {
        abs_n = @divFloor(abs_n, 10);
        count += 1;
    }
    return count;
}

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

test "simple test" {
    var list = std.ArrayList(i32).init(std.testing.allocator);
    defer list.deinit(); // try commenting this out and see if zig detects the memory leak!
    try list.append(42);
    try std.testing.expectEqual(@as(i32, 42), list.pop());
}
