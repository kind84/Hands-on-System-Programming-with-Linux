const std = @import("std");
const print = std.debug.print;

const MAX = 10000000; // 10 million
const WRAP: u32 = 16;

fn simplePrimegen(limit: u32) void {
    var num: u32 = 2;
    var is_prime: bool = false;

    print("     2,      3, ", .{});
    var i: u32 = 4;
    while (i < limit) : (i += 1) {
        is_prime = true;
        var j: u32 = 2;
        while (j < limit / 2) : (j += 1) {
            if ((i != j) and (i % j == 0)) {
                is_prime = false;
                break;
            }
        }
        if (is_prime) {
            num += 1;
            print("{d:6}, ", .{i});

            if (num % WRAP == 0) {
                print("\n", .{});
            }
        }
    }
    print("\n", .{});
}

fn setupCPURlimit(cpuLimit: i32) void {
    var rlim_new = std.os.rlimit{ .cur = 0, .max = 0 };
    var rlim_old = std.os.rlimit{ .cur = 0, .max = 0 };

    if (cpuLimit == -1) {
        rlim_new.cur = std.os.RLIM.INFINITY;
        rlim_new.max = std.os.RLIM.INFINITY;
    } else {
        rlim_new.cur = @intCast(std.os.rlim_t, cpuLimit);
        rlim_new.max = @intCast(std.os.rlim_t, cpuLimit);
    }

    if (std.os.linux.prlimit(0, std.os.rlimit_resource.CPU, &rlim_new, &rlim_old) == 1) {
        std.debug.panic("prlimit:cpu failed\n", .{});
    }

    print("CPU rlimit [soft,hard] new: [{d}:{d}]s : old [{d}:{d}]s (-1 = unlimited)\n", .{
        rlim_new.cur, rlim_new.max, rlim_old.cur, rlim_old.max,
    });
}

pub fn main() !void {
    var limit: u32 = 0;
    var n_sec: i32 = 0;

    var args = std.process.args();
    if (std.os.argv.len < 3) {
        print(
            \\Usage: {s} limit-to-generate-primes-upto CPU-time-limit
            \\ arg1 : max is {d}"
            \\ arg2 : CPU-time-limit:
            \\  -2 = don't set
            \\  -1 = unlimited
            \\   0 = 1s
            \\
        , .{
            std.os.argv[0],
            MAX,
        });
        std.os.exit(1);
    }
    _ = args.skip();

    var argv1 = args.next().?;
    limit = try std.fmt.parseInt(u32, argv1, 10);
    if (limit <= 4 or limit > MAX) {
        print(
            \\{s}: invalid value ({d}); pl pass a value within
            \\the range [4 - {d}].
            \\
        , .{
            std.os.argv[0],
            limit,
            MAX,
        });
        std.os.exit(1);
    }

    var argv2 = args.next().?;
    n_sec = try std.fmt.parseInt(i32, argv2, 10);
    if (n_sec == 0) {
        n_sec = 1;
    }
    if (n_sec != -2) {
        setupCPURlimit(n_sec);
    }

    simplePrimegen(limit);
}
