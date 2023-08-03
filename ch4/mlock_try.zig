const std = @import("std");

fn disp_locked_mem(allocator: std.mem.Allocator) !void {
    var pid = std.os.linux.getpid();
    var path = try std.fmt.allocPrint(allocator, "/proc/{d}/status", .{pid});
    defer allocator.free(path);
    var child = std.ChildProcess.init(&.{ "grep", "Lck", path }, allocator);

    try child.spawn();
    _ = try child.wait();
}

fn mlock_pages(allocator: std.mem.Allocator, num_pg: usize) !void {
    const pgsz: usize = std.mem.page_size;
    var len: usize = num_pg * pgsz;
    if (len >= std.math.maxInt(u32)) {
        return error.TooManyBytes;
    }

    var ptr = try allocator.alignedAlloc(u8, std.mem.page_size, len);
    defer allocator.free(ptr);

    var ok = std.os.linux.syscall2(std.os.linux.syscalls.X64.mlock, @intFromPtr(ptr.ptr), len);
    if (ok == 1) {
        return error.MLockFailure;
    }
    std.debug.print("Locked {d} bytes from address {*}\n", .{ len, ptr.ptr });

    // @memset(ptr.ptr, 'L');

    try disp_locked_mem(allocator);

    std.time.sleep(std.time.ns_per_s);

    ok = std.os.linux.syscall2(std.os.linux.syscalls.X64.munlock, @intFromPtr(ptr.ptr), len);
    if (ok == 1) {
        return error.MUnlockFailure;
    }
    std.debug.print("unlocked..\n", .{});
}

pub fn main() !void {
    var args = std.process.args();
    if (std.os.argv.len < 2) {
        std.debug.print("Usage: {s} pages-to-alloc\n", .{args.next().?});
        return;
    }

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer {
        var check = gpa.deinit();
        switch (check) {
            .leak => {
                @panic("leak");
            },
            else => {},
        }
    }

    try disp_locked_mem(allocator);

    _ = args.next();
    var cpgs = args.next().?;
    var num_pg = try std.fmt.parseInt(usize, cpgs, 10);

    try mlock_pages(allocator, num_pg);
}
