pub const Identifier = struct {
    namespace: []const u8,
    path: []const u8,

    pub fn init(namespace: []const u8, path: []const u8) Identifier {
        return .{ .namespace = namespace, .path = path };
    }

    pub fn initDefaultNamespace(path: []const u8) Identifier {
        return .{ .namespace = "minecraft", .path = path };
    }
};
