const std = @import("std");
const mem = std.mem;
const ArrayList = std.ArrayList;
const Allocator = mem.Allocator;
const assert = std.debug.assert;

pub const Impl = struct {
    cardinality: u32,
    toString: *const fn (u32) []const u8,
    fromString: *const fn ([]const u8) ?u32,
};

fn boolToString(int: u32) []const u8 {
    return switch (int) {
        0 => "false",
        1 => "true",
        else => unreachable,
    };
}

fn boolFromString(str: []const u8) ?u32 {
    if (mem.eql(u8, str, "true")) return 1;
    if (mem.eql(u8, str, "false")) return 0;
    return null;
}

const bool_property_impls = Impl{
    .cardinality = 2,
    .toString = boolToString,
    .fromString = boolFromString,
};

pub const Ref = extern struct {
    idx: u32,
};

pub const Registry = struct {
    impls: ArrayList(Impl),

    pub fn init() Registry {
        return .{ .impls = ArrayList(Impl){} };
    }

    pub fn deinit(registery: *Registry, gpa: Allocator) void {
        registery.impls.deinit(gpa);
    }

    pub fn register(registry: *Registry, gpa: Allocator, property: Impl) error{OutOfMemory}!Ref {
        const new_idx: u32 = @intCast(registry.impls.items.len);
        try registry.impls.append(gpa, property);

        return .{
            .idx = new_idx,
        };
    }

    pub fn get(registry: *Registry, ref: Ref) Impl {
        const idx: usize = @intCast(ref.idx);
        return registry.impls.items[idx];
    }
};

pub fn Range(comptime min: u32, comptime max: u32) type {
    return struct {
        isRangedPropertyType: struct {},
        // inclusive
        const min_value = min;
        // exclusive
        const max_value = max;
    };
}

pub fn Define(PropType: type) type {
    const type_info = @typeInfo(PropType);

    switch (type_info) {
        .bool => {
            return extern struct {
                ref: Ref,

                pub const impls = bool_property_impls;
            };
        },
        .@"enum" => {
            assert(type_info.@"enum".is_exhaustive);
            const FnImpls = struct {
                fn fromString(str: []const u8) ?u32 {
                    const tag = std.meta.stringToEnum(PropType, str) orelse return null;
                    return @intFromEnum(tag);
                }

                fn toString(int: u32) []const u8 {
                    const tag: PropType = @enumFromInt(int);
                    return @tagName(tag);
                }
            };
            const property_impls: Impl = .{
                .cardinality = @intCast(type_info.@"enum".fields.len),
                .fromString = FnImpls.fromString,
                .toString = FnImpls.toString,
            };
            return extern struct {
                ref: Ref,

                const impls = property_impls;
            };
        },
        .@"struct" => {
            if (@hasField(PropType, "isRangedPropertyType")) {
                const FnImpls = struct {
                    fn fromString(str: []const u8) ?u32 {
                        const num = std.fmt.parseInt(u32, str, 10) catch return null;
                        if (num < PropType.min_value) {
                            return null;
                        }
                        if (num >= PropType.max_value) {
                            return null;
                        }
                        return num - PropType.min_value;
                    }

                    fn toString(_: u32) []const u32 {
                        @panic("todo");
                    }
                };
                const property_impls: Impl = .{
                    .cardinality = PropType.max - PropType.max,
                    .fromString = FnImpls.fromString,
                    .toString = FnImpls.toString,
                };
                return extern struct {
                    ref: Ref,

                    const impls = property_impls;
                };
            }
        },
        else => {},
    }

    @compileError("Invalid Prop type");
}
