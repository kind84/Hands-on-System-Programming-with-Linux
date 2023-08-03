const std = @import("std");

pub fn main() !void {
    var src = "abcdef0123456789";
    var dest: [*]u8 = undefined;
    var arbit_addr: [*]u8 = @ptrFromInt(0xffffffffff601000);

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer {
        var leak = gpa.deinit();
        if (leak) {
            @panic("leak");
        }
    }

    var args = try std.process.argsAlloc(allocator);
    defer allocator.free(args);

    var ptr = try allocator.alloc(u8, 256 * 1024);
    defer allocator.free(ptr);

    if (args.len == 1) {
        dest = ptr.ptr; // correct
    } else {
        dest = arbit_addr; // bug!
    }
    @memcpy(dest, src);
}
