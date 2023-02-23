const std = @import("std");
const print = std.debug.print;
const malloc = std.heap.raw_c_allocator;

pub fn main() !void {
    maxMalloc();
    try negativeMalloc();
}

fn maxMalloc() void {
    const usz = @sizeOf(usize);

    print("*** {s}() ***\n", .{@src().fn_name});
    var max = std.math.pow(f32, 2, usz * 8);
    print("sizeof usize = {d}; max value of the param to malloc = {d}\n", .{ usz, max });
}

fn negativeMalloc() !void {
    const usz = @sizeOf(usize);
    const onePB: usize = 1125899907000000; // 1 petabyte
    const qa: usize = 28 * 1000000;

    // var usz_num2alloc: usize = qa * onePB; // error: overflow of integer type 'usize' with value '31525197396000000000000'
    var usz_num2alloc: usize = @mulWithOverflow(qa, onePB)[0];
    // var ld_num2alloc: i64 = @intCast(i64, usz_num2alloc); // panic: integer cast truncated bits
    var sd_num2alloc: i16 = undefined;
    var slice: []u8 = undefined;

    print("*** {s}() ***\n", .{@src().fn_name});

    var max = std.math.pow(f32, 2, usz * 8);
    print("usize max     = {d}\n", .{max});

    // print("ld_num2alloc  = {d}\nusz_num2alloc = {d}\n", .{ ld_num2alloc, usz_num2alloc });

    // slice = try malloc.alloc(u8, ld_num2alloc); // error: expected type 'usize', found 'i64'
    // print("1. i64 used:    malloc({d}) returns {*}\n", .{ ld_num2alloc, slice });
    // malloc.free(slice);

    // slice = try malloc.alloc(u8, usz_num2alloc); // error: OutOfMemory
    if (malloc.alloc(u8, usz_num2alloc)) |slc| {
        print("2. usize used:  malloc({d}) returns {*}\n", .{ usz_num2alloc, slc });
        malloc.free(slc);
    } else |err| {
        print("2. usize used:  malloc({d}) returns {any}\n", .{ usz_num2alloc, err });
    }

    sd_num2alloc = 6 * 1024;
    // slice = try malloc.alloc(u8, sd_num2alloc); // error: expected type 'usize', found 'i16'
    // print("3. i64 used:    malloc({d}) returns {*}\n", .{ sd_num2alloc, slice });
    // malloc.free(slice);

    // sd_num2alloc = 60 * 1024; // error: type 'i16' cannot represent integer value '61440'
    var a: i64 = 60;
    var b: i64 = 1024;
    var i64_num2alloc = @mulWithOverflow(a, b)[0];
    sd_num2alloc = @truncate(i16, i64_num2alloc);
    // slice = try malloc.alloc(u8, sd_num2alloc); // error: expected type 'usize', found 'i16'
    // print("4. i64 used:    malloc({d}) returns {*}\n", .{ sd_num2alloc, slice });
    // malloc.free(slice);

    // usz_num2alloc = @intCast(usize, sd_num2alloc); // panic: attempt to cast negative value to unsigned integer
    // slice = try malloc.alloc(u8, usz_num2alloc);
    // print("5. usize used:  malloc({d}) returns {*}\n", .{ usz_num2alloc, slice });
    // malloc.free(slice);

    if (malloc.alloc(u8, std.math.maxInt(u64))) |slc| {
        print("6.              malloc({d}) returns {*}\n", .{ std.math.maxInt(u64), slc });
        malloc.free(slice);
    } else |err| {
        print("6.              malloc({d}) returns {any}\n", .{ std.math.maxInt(u64), err });
    }

    slice = try malloc.alloc(u8, 0);
    print("7.              malloc(0) returns {*}\n", .{slice});
    malloc.free(slice);
}
