const std = @import("std");

fn arr(allocator: std.mem.Allocator) std.mem.Allocator.Error![]u8 {
    const buffer = allocator.alloc(u8, 10);
    return buffer;
}
