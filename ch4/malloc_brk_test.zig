const std = @import("std");
const print = std.debug.print;
const malloc = std.heap.raw_c_allocator;

const TRIES: usize = 5;

var gFlag_show_mstats = false;
var gFlag_large_allocs = false;
var gFlag_test_segfault1 = false;
var gFlag_test_segfault2 = false;

var heap_ptr: [5][]u8 = undefined;

var init_brk: usize = undefined;

fn alloctest(index: usize, num: usize) !void {
    var slc = try malloc.alloc(u8, num);

    heap_ptr[index] = slc; // save ptr in order to free later..

    var sbrk = std.os.linux.syscall1(std.os.linux.syscalls.X64.brk, 0);

    print("{d:2}: malloc({d:8}) = ", .{ index, num });
    print("{x:>22} ", .{@intFromPtr(slc.ptr)});
    print("          {x} [{d}]\n", .{ sbrk, (sbrk - init_brk) });
}

fn usage(name: [:0]const u8) void {
    print(
        \\Usage: {s} [option | --help]
        \\ option = 0 : show only mem pointers [default]
        \\ option = 1 : opt 0 + show malloc stats as well
        \\ option = 2 : opt 1 + perform larger alloc's (over MMAP_THRESHOLD)
        \\ option = 3 : test segfault 1
        \\ option = 4 : test segfault 2
        \\-h | --help : show this help screen
    , .{name});
}

fn process_args() !void {
    var args = std.process.args();
    var argc = std.os.argv.len;
    var name = args.next().?;
    if (argc == 2) {
        var param = args.next().?;
        if (std.mem.eql(u8, param, "-h") or std.mem.eql(u8, param, "--help")) {
            usage(name);
            std.os.exit(0);
        }

        var opt = try std.fmt.parseInt(u8, param, 10);
        switch (opt) {
            1 => gFlag_show_mstats = true,
            2 => {
                gFlag_show_mstats = true;
                gFlag_large_allocs = true;
            },
            3 => gFlag_test_segfault1 = true,
            4 => gFlag_test_segfault2 = true,
            else => {
                usage(name);
                std.os.exit(1);
            },
        }
    }
}

pub fn main() !void {
    var i: usize = 1;
    var q: *volatile u8 = undefined;
    _ = q;

    try process_args();

    init_brk = std.os.linux.syscall1(std.os.linux.syscalls.X64.brk, 0);

    print("                              init_brk = {x}\n", .{init_brk});
    print(" #: malloc(       n) =              heap_ptr           cur_brk   delta [cur_brk-init_brk]\n", .{});

    try alloctest(i, 8);
    try alloctest(i, (std.mem.page_size - 8 - 5));
    i += 1;
    try alloctest(i, 3);
    i += 1;

    if (gFlag_large_allocs) {
        var cur_brk = std.os.linux.syscall1(std.os.linux.syscalls.X64.brk, 0);
        i += 1;

        // This allocation request is a large one: ~132Kb. The
        // 'mmap threshold' is (default) 128Kb; thus, this causes an
        // mmap() to the process virtual address space, mapping in the
        // virtually allocated region (which will later be mapped to
        // physical page frames via the MMU page-faulting on
        // application access to these memory regions!
        //
        try alloctest(i, cur_brk - init_brk + 1000);

        try alloctest(i, 1024 * 1024);
    }

    while (i > 0) : (i -= 1) {
        malloc.free(heap_ptr[i]);
    }
}
