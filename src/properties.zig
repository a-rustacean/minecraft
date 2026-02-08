const std = @import("std");

fn Property(comptime PV: type) type {
    return struct {
        id: u32,

        pub const Type = PV;
    };
}

pub fn DefineProperties(comptime Props: type) type {
    const props_fields = @typeInfo(Props).@"struct".fields;
    var field_names: [props_fields.len][]const u8 = undefined;
    var field_types: [props_fields.len]type = undefined;
    var field_attrs: [props_fields.len]std.builtin.Type.StructField.Attributes = undefined;

    inline for (props_fields, 0..) |field, i| {
        field_names[i] = field.name;
        field_types[i] = Property(field.type);
        field_attrs[i] = .{};
    }

    const Prop2 = @Struct(.auto, null, &field_names, &field_types, &field_attrs);

    return struct {
        properties: Prop2,

        pub fn init(offset: u32) @This() {
            const fields = @typeInfo(Prop2).@"struct".fields;
            var result: Prop2 = undefined;
            var id: u32 = offset;

            inline for (fields) |field| {
                @field(result, field.name) = .{ .id = id };
                id += 1;
            }

            return .{ .properties = result };
        }
    };
}

pub const Properties = DefineProperties(struct {});
