const api = @import("api");
const Interface = api.Interface;

const Properties = @import("./properties.zig").Properties;

pub const Module = Interface.ModuleInterface(Properties);
