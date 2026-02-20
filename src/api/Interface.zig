const std = @import("std");
const Allocator = std.mem.Allocator;

const Property = @import("./Property.zig");
const abi = @import("./abi.zig");

pub const Registries = extern struct {
    property: *Property.Registry,
};

pub const Mod = extern struct {
    properties: *anyopaque,
};

pub const InitRet = abi.Type(error{OutOfMemory}!Mod);

pub inline fn modInit(Properties: type, registries: *Registries, gpa: *Allocator) InitRet {
    return abi.wrap(modInitZig(Properties, registries, gpa.*));
}

inline fn modInitZig(Properties: type, registries: *Registries, gpa: Allocator) error{OutOfMemory}!Mod {
    const properties = try Properties.init(registries.property, gpa);
    const properties_ptr = try gpa.create(Properties);
    properties_ptr.* = properties;

    return .{
        .properties = @ptrCast(properties_ptr),
    };
}
