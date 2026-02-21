const std = @import("std");
const Property = @import("./Property.zig");
const assert = std.debug.assert;
const Type = std.builtin.Type;
const Allocator = std.mem.Allocator;
const ArrayList = std.ArrayList;

pub const Registry = struct {
    impls: ArrayList(Property.Impl),

    pub fn init() Registry {
        return .{ .impls = .{} };
    }

    pub fn deinit(registery: *Registry, gpa: Allocator) void {
        registery.impls.deinit(gpa);
    }

    pub fn register(registry: *Registry, gpa: Allocator, property: Property.Impl) error{OutOfMemory}!Property.Ref {
        const new_idx: u32 = @intCast(registry.impls.items.len);
        try registry.impls.append(gpa, property);

        return .{
            .idx = new_idx,
        };
    }

    pub fn get(registry: *Registry, ref: Property.Ref) Property.Impl {
        const idx: usize = @intCast(ref.idx);
        return registry.impls.items[idx];
    }
};

pub fn Define(PropertiesSchema: type) type {
    const type_info = @typeInfo(PropertiesSchema);
    assert(type_info == .@"struct");
    const fields = type_info.@"struct".fields;
    var field_names: [fields.len][]const u8 = undefined;
    var field_types: [fields.len]type = undefined;
    var field_attrs: [fields.len]Type.StructField.Attributes = undefined;

    for (fields, 0..) |field, i| {
        field_names[i] = field.name;
        field_types[i] = Property.Define(field.type);
        field_attrs[i] = .{};
    }

    const PropertyRefs = @Struct(
        .@"extern",
        null,
        &field_names,
        &field_types,
        &field_attrs,
    );

    return struct {
        const Self = @This();
        refs: PropertyRefs,

        pub fn init(registry: *Registry, gpa: Allocator) error{OutOfMemory}!Self {
            const ref_fields = @typeInfo(PropertyRefs).@"struct".fields;
            var result: PropertyRefs = undefined;

            inline for (ref_fields) |field| {
                const ref = try registry.register(gpa, field.type.impls);
                @field(result, field.name) = .{ .ref = ref };
            }

            return .{ .refs = result };
        }
    };
}
