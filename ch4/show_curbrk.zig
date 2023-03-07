const std = @import("std");
const print = std.debug.print;
const malloc = std.heap.raw_c_allocator;

pub fn main() !void {
    var num: usize = 2048;

    // sbrk not implemented in zig, using brk syscall
    var orig_brk = std.os.linux.syscall1(std.os.linux.syscalls.X64.brk, 0);

    var args = std.process.args();

    // No params, just print the current break and exit
    if (std.os.argv.len == 1) {
        print("Current program break =  0x{x}\n", .{orig_brk});
        return;
    }

    // If passed a param - the number of bytes of memory to
    // dynamically allocate -, perform a dynamic alloc, then
    // print the heap address, the current break and exit.
    //
    _ = args.next();
    var argv1 = args.next().?;
    num = try std.fmt.parseInt(u32, argv1, 10);
    if (num >= 128 * 1024) {
        @panic("pl pass a value < 128 KB");
    }

    print("Original program break = 0x{x}\n", .{orig_brk});

    if (malloc.alloc(u8, num)) |slc| {
        var cur_brk = std.os.linux.syscall1(std.os.linux.syscalls.X64.brk, 0);
        defer malloc.free(slc);
        print("malloc({d}) =             0x{x}\ncurr break =             0x{x}\n", .{ num, @ptrToInt(slc.ptr), cur_brk });
    } else |err| {
        print("malloc failed! {any}\n", .{err});
    }
}
