const std = @import("std");
const assert = std.debug.assert;

fn log(
    comptime log_fn: fn (comptime format: []const u8, args: anytype) void,
    comptime message: []const u8,
    values: anytype,
) void {
    const Values = @TypeOf(values);
    assert(@typeInfo(Values) == .@"struct");
    const fields = @typeInfo(Values).@"struct".fields;

    if (fields.len == 0) {
        log_fn(message, .{});
        return;
    }

    comptime var format: []const u8 = message ++ ".";
    comptime var types: [fields.len]type = undefined;
    inline for (fields, 0..) |field, i| {
        comptime var clause: []const u8 = "{any}";
        switch (@typeInfo(field.type)) {
            .int => |t| {
                if (t.signedness == .unsigned and t.bits == 8) {
                    clause = "{c}"; // single byte as character
                }
            },
            .array => |t| {
                const child_info = @typeInfo(t.child);
                if (child_info == .int) {
                    const ci = child_info.int;
                    if (ci.signedness == .unsigned and ci.bits == 8) {
                        clause = "{s}"; // byte array prints as string
                    }
                }
            },
            .pointer => |p| {
                const child_info = @typeInfo(p.child);
                if (p.size == .slice and child_info == .int) {
                    const ci = child_info.int;
                    if (ci.signedness == .unsigned and ci.bits == 8) {
                        clause = "{s}";
                    }
                } else if (child_info == .array) {
                    const arr = child_info.array;
                    const elem_info = @typeInfo(arr.child);
                    if (elem_info == .int) {
                        const ei = elem_info.int;
                        if (ei.signedness == .unsigned and ei.bits == 8) {
                            clause = "{s}";
                        }
                    }
                }
            },
            else => {},
        }
        format = format ++ " " ++ field.name ++ "=" ++ clause;
        types[i] = field.type;
    }

    const Tuple = std.meta.Tuple(&types);
    var args: Tuple = undefined;
    inline for (fields, 0..) |field, i| {
        args[i] = @field(values, field.name);
    }

    log_fn(format, args);
}

pub fn debug(comptime message: []const u8, values: anytype) void {
    log(std.log.debug, message, values);
}

pub fn info(comptime message: []const u8, values: anytype) void {
    log(std.log.info, message, values);
}

pub fn warn(comptime message: []const u8, values: anytype) void {
    log(std.log.warn, message, values);
}

pub fn err(comptime message: []const u8, values: anytype) void {
    log(std.log.err, message, values);
}

pub fn scoped(comptime scope: @TypeOf(.enum_literal)) type {
    const std_scope = std.log.scoped(scope);

    return struct {
        const Self = @This();

        pub fn debug(comptime message: []const u8, values: anytype) void {
            log(std_scope.debug, message, values);
        }

        pub fn info(comptime message: []const u8, values: anytype) void {
            log(std_scope.info, message, values);
        }

        pub fn warn(comptime message: []const u8, values: anytype) void {
            log(std_scope.warn, message, values);
        }

        pub fn err(comptime message: []const u8, values: anytype) void {
            log(std_scope.err, message, values);
        }
    };
}
