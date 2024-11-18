const std = @import("std");
const util = @import("../util.zig");

pub fn main(input_file: []const u8) !void {
    var in = try std.fs.cwd().openFile(input_file, .{ .mode = .read_only });
    defer in.close();

    const allocator = std.heap.page_allocator;
    var file_contents = try in.readToEndAlloc(allocator, std.math.maxInt(usize));
    defer allocator.free(file_contents);

    // Strip the final newline if it exists
    if (file_contents.len > 0 and file_contents[file_contents.len - 1] == '\n') {
        file_contents = file_contents[0 .. file_contents.len - 1];
    }

    const lines = try util.parseInto2DArray(allocator, file_contents);
    defer lines.deinit();

    var sum: u32 = 0;
    for (lines.items) |line| {
        var card = std.mem.tokenizeAny(u8, line, ":|");
        _ = card.next();
        var win_nums_str = std.mem.tokenizeScalar(u8, card.next().?, ' ');
        var win_nums = std.AutoHashMap(u32, void).init(allocator);
        while (win_nums_str.next()) |num_str| {
            const num = try std.fmt.parseInt(u32, num_str, 10);
            try win_nums.put(num, {});
        }

        var my_nums_str = std.mem.tokenizeScalar(u8, card.next().?, ' ');
        var card_score: u32 = 0;
        while (my_nums_str.next()) |num_str| {
            const num = try std.fmt.parseInt(u32, num_str, 10);

            if (win_nums.contains(num)) {
                card_score = if (card_score == 0) 1 else card_score * 2;
            }
        }
        sum += card_score;
    }

    std.debug.print("{d}\n", .{sum});
}
