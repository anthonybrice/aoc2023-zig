const std = @import("std");
const util = @import("../util.zig");

const Card = struct {
    const Self = @This();
    win_nums: std.AutoHashMap(u32, void),
    my_nums: []u32,
    copies: u32,
    allocator: std.mem.Allocator,

    pub fn init(
        allocator: std.mem.Allocator,
        win_nums: std.AutoHashMap(u32, void),
        my_nums: []u32,
    ) Card {
        return Card{
            .allocator = allocator,
            .win_nums = win_nums,
            .my_nums = my_nums,
            .copies = 1,
        };
    }

    pub fn deinit(self: *Self) void {
        self.win_nums.deinit();
        self.allocator.free(self.my_nums);
    }

    pub fn format(
        self: Self,
        comptime _: []const u8,
        _: std.fmt.FormatOptions,
        writer: anytype,
    ) !void {
        try std.fmt.format(
            writer,
            "Card(copies: {}, win_nums: {}, my_nums: {})",
            .{ self.copies, self.win_nums.count(), self.my_nums.len },
        );
    }
};

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

    var card_list = std.ArrayList(Card).init(allocator);
    defer {
        for (card_list.items) |*card| {
            card.deinit();
        }
        card_list.deinit();
    }
    for (lines.items) |line| {
        var card_tokens = std.mem.tokenizeAny(u8, line, ":|");
        _ = card_tokens.next();
        var win_nums_str = std.mem.tokenizeScalar(u8, card_tokens.next().?, ' ');
        var win_nums = std.AutoHashMap(u32, void).init(allocator);
        while (win_nums_str.next()) |num_str| {
            const num = try std.fmt.parseInt(u32, num_str, 10);
            try win_nums.put(num, {});
        }

        var my_nums_str = std.mem.tokenizeScalar(u8, card_tokens.next().?, ' ');
        var my_nums = std.ArrayList(u32).init(allocator);
        while (my_nums_str.next()) |num_str| {
            const num = try std.fmt.parseInt(u32, num_str, 10);
            try my_nums.append(num);
        }

        const card = Card.init(
            allocator,
            win_nums,
            try my_nums.toOwnedSlice(),
        );

        try card_list.append(card);
    }

    const sum = scratchCards(&card_list);
    std.debug.print("{d}\n", .{sum});
}

fn scratchCards(card_list: *std.ArrayList(Card)) u32 {
    for (card_list.items, 0..) |card, idx| {
        var matching_numbers: u32 = 0;
        for (card.my_nums) |num| {
            if (card.win_nums.contains(num)) matching_numbers += 1;
        }
        if (matching_numbers >= 1) {
            for (1..matching_numbers + 1) |i| {
                card_list.items[idx + i].copies += (1 * card.copies);
            }
        }
    }

    var sum: u32 = 0;
    for (card_list.items) |card| {
        sum += card.copies;
    }

    return sum;
}
