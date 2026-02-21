const std = @import("std");
const Allocator = std.mem.Allocator;

const api = @import("api");
const Interface = api.Interface;

const Properies = @import("./properties.zig").Properties;

export fn init_mod(registries: *Interface.Registries, gpa: *Allocator) Interface.InitRet {
    return Interface.modInit(
        Properies,
        registries,
        gpa,
    );
}
