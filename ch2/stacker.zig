const std = @import("std");

pub fn main() void {
    var localvar: i32 = 5;

    std.debug.print("In function {s}; &localvar = {}\n", .{ @src().fn_name, &localvar });
    foo();
    std.os.exit(0);
}

fn foo() void {
    var localvar: i32 = 5;

    std.debug.print("In function {s}; &localvar = {}\n", .{ @src().fn_name, &localvar });
    bar();
}

fn bar() void {
    var localvar: i32 = 5;

    std.debug.print("In function {s}; &localvar = {}\n", .{ @src().fn_name, &localvar });
    barIsNowClosed();
}

fn barIsNowClosed() void {
    var localvar: i32 = 5;

    std.debug.print(
        \\In function {s}; &localvar = {}
        \\    (bye, pl go '~/' now).
        \\
    , .{ @src().fn_name, &localvar });
    std.debug.print(
        \\ Now blocking on pause()...
        \\ Connect via GDB's 'attach' and then issue the 'bt' command
        \\ to view the process stack
    , .{});
    _ = std.os.linux.syscall0(std.os.linux.syscalls.X64.pause); // process blocks here until it receives a signal
}
