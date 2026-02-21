const std = @import("std");
const Allocator = std.mem.Allocator;
const Property = @import("./Property.zig");

pub const Impl = struct {
    /// The unique namespaced ID (e.g., "`minecraft:diamond_ore`").
    name: []const u8,
    /// The key used for client-side localization (e.g., "`block.minecraft.diamond_ore`")
    translation_key: []const u8,
    /// How hard the block is to break. A value of -1.0 indicates an unbreakable block (e.g., Bedrock).
    hardness: f32,
    /// The block's resistance to explosions.
    blast_resistance: f32,
    /// The friction coefficient. Default is 0.6; Ice is 0.98.
    slipperiness: f32 = 0.6,
    /// How much this block affects the speed of an entity walking on it (e.g., Soul Sand).
    velocity_multiplier: f32,
    /// How much this block affects an entity's jump height (e.g., Honey Blocks).
    jump_velocity_multiplier: f32,
    // fn(ptr_to_self_properties, all_deps) all_the_properties_this_block_have
    properties: *const fn (gpa: Allocator, *const anyopaque, *const anyopaque) error{OutOfMemory}![]const Property.Ref,
};

const Ref = struct { idx: u32 };

pub fn Define(Properties: type, Deps: type, schema: type) type {
    const properties_fn = struct {
        fn properties_fn(gpa: Allocator, opaque_properties: *const anyopaque, opaque_deps: *const anyopaque) error{OutOfMemory}![]const Property.Ref {
            const properties: *const Properties = @ptrCast(@alignCast(opaque_properties));
            const deps: *const Deps = @ptrCast(@alignCast(opaque_deps));

            return schema.properties(gpa, properties, deps);
        }
    }.properties_fn;

    return struct {
        ref: Ref,

        const impl: Impl = .{
            .name = schema.name,
            .translation_key = schema.translation_key,
            .hardness = schema.hardness,
            .blast_resistance = schema.blast_resistance,
            .slipperiness = schema.slipperiness,
            .velocity_multiplier = schema.velocity_multiplier,
            .jump_velocity_multiplier = schema.velocity_multiplier,
            .properties = properties_fn,
        };
    };
}

test "dirt test" {
    // const std = @import("std");
    const testing = std.testing;
    const allocator = testing.allocator;

    const Properties = @import("./Properties.zig");

    const DirtProperties = Properties.Define(struct {
        anything_else: bool,
        something_else: bool,
        snowy: bool,
    });

    const Deps = struct {};

    var properties_registry = Properties.Registry.init();
    defer properties_registry.deinit(allocator);

    const dirt_properties = try DirtProperties.init(&properties_registry, allocator);

    const DirtDef = Define(DirtProperties, Deps, struct {
        const name = "dirt";
        const translation_key = "block.minecraft.dirt";
        const hardness = 1.0;
        const blast_resistance = 1.0;
        const slipperiness = 0.6;
        const velocity_multiplier = 1.0;
        const jump_velocity_multiplier = 1.0;

        fn properties(gpa: Allocator, props: *const DirtProperties, _: *const Deps) ![]const Property.Ref {
            return gpa.dupe(Property.Ref, &.{props.refs.snowy.ref});
        }
    });

    const property_refs = try DirtDef.impl.properties(allocator, @ptrCast(&dirt_properties), @ptrCast(&.{}));
    defer allocator.free(property_refs);

    try testing.expectEqual(property_refs.len, 1);
    try testing.expectEqual(property_refs[0].idx, 2);

    const snowy_property = properties_registry.get(property_refs[0]);
    try testing.expectEqual(snowy_property.cardinality, 2);
}
