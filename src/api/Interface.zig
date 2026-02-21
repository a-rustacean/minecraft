const std = @import("std");
const Allocator = std.mem.Allocator;

const Property = @import("./Property.zig");
const Properties = @import("./Properties.zig");
const abi = @import("./abi.zig");

pub const Registries = extern struct {
    property: *Properties.Registry,
};

pub const Mod = extern struct {
    properties: *anyopaque,
};

pub const InitRet = abi.Type(error{OutOfMemory}!Mod);

pub inline fn modInit(ModProperties: type, registries: *Registries, gpa: *Allocator) InitRet {
    return abi.wrap(modInitZig(ModProperties, registries, gpa.*));
}

inline fn modInitZig(ModProperties: type, registries: *Registries, gpa: Allocator) error{OutOfMemory}!Mod {
    const properties = try ModProperties.init(registries.property, gpa);
    const properties_ptr = try gpa.create(ModProperties);
    properties_ptr.* = properties;

    return .{
        .properties = @ptrCast(properties_ptr),
    };
}

pub fn ModuleInterface(ModProperties: type) type {
    return struct {
        properties: ModProperties,
    };
}
