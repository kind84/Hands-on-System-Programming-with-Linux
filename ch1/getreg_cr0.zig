const std = @import("std");

comptime {
    asm (
        \\.global getcr0;
        \\.type getcr0, @function;
        \\getcr0:
        \\  movq %cr0, %rax
        \\  retq
    );
}

extern fn getcr0() u64;

pub fn main() void {
    std.debug.print("Hello, inline assembly:\n [CR0] = 0x{x}\n", .{getcr0()});
}
