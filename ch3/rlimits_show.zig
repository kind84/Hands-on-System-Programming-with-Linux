const std = @import("std");

pub fn main() !void {
    try queryRLimits();
}

fn queryRLimits() !void {
    var rlim: std.os.rlimit = undefined;
    const rlimpair = struct {
        rlim: usize,
        name: []const u8,
    };
    const rlimpair_arr = &[_]rlimpair{
        rlimpair{ .rlim = @enumToInt(std.os.rlimit_resource.CORE), .name = "RLIMIT_CORE" },
        rlimpair{ .rlim = @enumToInt(std.os.rlimit_resource.DATA), .name = "RLIMIT_DATA" },
        rlimpair{ .rlim = @enumToInt(std.os.rlimit_resource.NICE), .name = "RLIMIT_NICE" },
        rlimpair{ .rlim = @enumToInt(std.os.rlimit_resource.FSIZE), .name = "RLIMIT_FSIZE" },
        rlimpair{ .rlim = @enumToInt(std.os.rlimit_resource.SIGPENDING), .name = "RLIMIT_SIGPENDING" },
        rlimpair{ .rlim = @enumToInt(std.os.rlimit_resource.MEMLOCK), .name = "RLIMIT_MEMLOCK" },
        rlimpair{ .rlim = @enumToInt(std.os.rlimit_resource.NOFILE), .name = "RLIMIT_NOFILE" },
        rlimpair{ .rlim = @enumToInt(std.os.rlimit_resource.MSGQUEUE), .name = "RLIMIT_MSGQUEUE" },
        rlimpair{ .rlim = @enumToInt(std.os.rlimit_resource.RTTIME), .name = "RLIMIT_RTTIME" },
        rlimpair{ .rlim = @enumToInt(std.os.rlimit_resource.STACK), .name = "RLIMIT_STACK" },
        rlimpair{ .rlim = @enumToInt(std.os.rlimit_resource.CPU), .name = "RLIMIT_CPU" },
        rlimpair{ .rlim = @enumToInt(std.os.rlimit_resource.NPROC), .name = "RLIMIT_NPROC" },
        rlimpair{ .rlim = @enumToInt(std.os.rlimit_resource.AS), .name = "RLIMIT_AS" },
        rlimpair{ .rlim = @enumToInt(std.os.rlimit_resource.LOCKS), .name = "RLIMIT_LOCKS" },
    };
    std.debug.print("RESOURCE LIMIT                 SOFT              HARD\n", .{});
    var i: u8 = 0;
    while (i < rlimpair_arr.len) : (i += 1) {
        var tmp1: [16]u8 = undefined;
        var tmp2: [16]u8 = undefined;
        var soft: []u8 = undefined;
        var hard: []u8 = undefined;

        if (std.os.linux.syscall4(std.os.linux.syscalls.X64.prlimit64, 0, rlimpair_arr[i].rlim, 0, @ptrToInt(&rlim)) == -1) {
            std.debug.panic("prlimit[{d}] failed\n", .{i});
        }
        if (rlim.cur != std.math.maxInt(u64)) {
            soft = try std.fmt.bufPrint(&tmp1, "{d}", .{rlim.cur});
        } else {
            soft = try std.fmt.bufPrint(&tmp1, "unlimited", .{});
        }
        if (rlim.max != std.math.maxInt(u64)) {
            hard = try std.fmt.bufPrint(&tmp2, "{d}", .{rlim.max});
        } else {
            hard = try std.fmt.bufPrint(&tmp2, "unlimited", .{});
        }
        std.debug.print("{s:<18}:  {s:16}  {s:16}\n", .{
            rlimpair_arr[i].name,
            soft,
            hard,
        });
    }
}
