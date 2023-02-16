const std = @import("std");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    var allocator = gpa.allocator();
    var buf = try allocator.alloc(u8, 3);
    defer allocator.free(buf);
    var buf_ptr = buf.ptr;
    var sgflt_ptr = buf_ptr + (10000000 * @sizeOf(u8));
    var rlim = std.os.rlimit{ .cur = 0, .max = 0 };
    if (std.os.linux.prlimit(0, std.os.rlimit_resource.CORE, &rlim, null) == -1) {
        std.debug.panic("prlimit:cpu failed\n", .{});
    }
    std.mem.copy(u8, sgflt_ptr[0..3], buf);
}
