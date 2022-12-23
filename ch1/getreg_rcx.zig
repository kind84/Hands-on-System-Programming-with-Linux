const std = @import("std");

comptime {
    asm (
        \\.global getrcx;
        \\.type getrcx, @function;
        \\getrcx:
        \\  push %rcx
        \\  movq $5, %rcx
        \\  movq %rcx, %rax
        \\  pop %rcx
        \\  retq
    );
}

extern fn getrcx() u64;

pub fn main() void {
    std.debug.print("Hello, inline assembly:\n [RCX] = 0x{x}\n", .{getrcx()});
}
