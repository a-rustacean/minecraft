const std = @import("std");
const builtin = @import("builtin");

const abi = @This();

pub const ccv: std.builtin.CallingConvention = switch (builtin.target.cpu.arch) {
    .x86 => .{ .x86_fastcall = .{} },
    .x86_64 => .{ .x86_64_sysv = .{} },
    .aarch64 => switch (builtin.target.os.tag) {
        // XXX: LLVM does not support callconv(.aarch64_aapcs) on other targets
        //      this is a hack and not a solution, as there are quite a bit of differences from aapcs
        //      <https://github.com/llvm/llvm-project/blob/64c40590c02429ee9dba422f9a58b45fa713f401/llvm/lib/Target/AArch64/AArch64CallingConvention.td#L366>
        .macos, .ios, .watchos, .visionos, .tvos => .{ .aarch64_aapcs_darwin = .{} },
        // TODO: check that compiler does not use the x18 register
        //       x18 register is platform register and many OSes forbid its use
        //       linux allows its use, but since we compile to freestanding idk
        //       what llvm is going to do
        else => .{ .aarch64_aapcs = .{} },
    },
    .arm, .armeb, .thumb, .thumbeb => switch (builtin.target.abi.float()) {
        .soft => .{ .arm_aapcs = .{} },
        .hard => .{ .arm_aapcs_vfp = .{} },
    },
    .mips, .mipsel => .{ .mips_o32 = .{} },
    .riscv32 => .{ .riscv32_ilp32 = .{} },
    .wasm32, .wasm64 => .{ .wasm_mvp = .{} },
    else => |arch| @compileError(std.fmt.comptimePrint("unsupported target: {s}", .{@tagName(arch)})),
};

pub const Export = struct {
    name: [:0]const u8,
    type: type,
};

pub const Import = struct {
    name: [:0]const u8,
    ptr: **const anyopaque,
};

pub const ExtensionInformation = struct {
    stable: bool,
    imports: []const Import,
};

pub const Mutability = enum { mutable, immutable };

pub fn Slice(mutability: Mutability, T: type) type {
    const ZigSlice = switch (mutability) {
        .mutable => []T,
        .immutable => []const T,
    };

    const backing = std.meta.Int(.unsigned, @bitSizeOf(usize) * 2);
    return switch (builtin.target.cpu.arch) {
        // wasm has well-defined semantics for passing 128-bit integers
        // passing the slice as a packed struct saves javascript bindings having
        // to read the struct from a memory
        .wasm32, .wasm64 => packed struct(backing) {
            ptr: switch (mutability) {
                .mutable => [*]T,
                .immutable => [*]const T,
            },
            len: usize,

            pub const empty: @This() = .{ .ptr = undefined, .len = 0 };

            pub fn wrap(slice: ZigSlice) @This() {
                return .{
                    .ptr = slice.ptr,
                    .len = slice.len,
                };
            }

            pub fn unwrap(self: @This()) ZigSlice {
                return self.ptr[0..self.len];
            }
        },
        // on native targets use extern struct as passing 128-bit integers may
        // not be well defined and passing small structs like this is not a problem
        else => extern struct {
            ptr: switch (mutability) {
                .mutable => [*]T,
                .immutable => [*]const T,
            },
            len: usize,

            pub const empty: @This() = .{ .ptr = undefined, .len = 0 };

            pub fn wrap(slice: ZigSlice) @This() {
                return .{
                    .ptr = slice.ptr,
                    .len = slice.len,
                };
            }

            pub fn unwrap(self: @This()) ZigSlice {
                return self.ptr[0..self.len];
            }
        },
    };
}

pub fn TaggedUnion(T: type) type {
    std.debug.assert(@typeInfo(T).@"union".layout == .@"extern");
    const Field = std.meta.FieldEnum(T);
    std.debug.assert(@sizeOf(Field) <= @sizeOf(u8));
    return extern struct {
        payload: T,
        tag: u8,

        // no wrap/unwrap as only used for error unions
        // if situation ever changes then improve this

        pub fn init(comptime field: Field, value: @FieldType(T, @tagName(field))) @This() {
            var this: @This() = undefined;
            this.set(field, value);
            return this;
        }

        pub fn activeField(self: @This()) Field {
            return @enumFromInt(self.tag);
        }

        pub fn get(self: @This(), comptime field: Field) @FieldType(T, @tagName(field)) {
            if (self.activeField() != field) unreachable;
            return @field(self.payload, @tagName(field));
        }

        pub fn set(self: *@This(), comptime field: Field, value: @FieldType(T, @tagName(field))) void {
            self.tag = @intFromEnum(field);
            @field(self.payload, @tagName(field)) = value;
        }
    };
}

pub fn ErrorSet(T: type) type {
    const errors = @typeInfo(T).error_set.?;
    var field_names: [errors.len][]const u8 = undefined;
    var field_values: [errors.len]u16 = undefined;

    for (errors, &field_names, &field_values, 0..) |e, *n, *v, idx| {
        n.* = e.name;
        v.* = @intCast(idx);
    }

    return @Enum(u16, .nonexhaustive, &field_names, &field_values);
}

pub fn mapToAbiError(T: type, zig_err: T) ErrorSet(T) {
    @branchHint(.cold);
    inline for (@typeInfo(T).error_set.?, 0..) |field, idx| {
        if (@field(T, field.name) == zig_err) return @enumFromInt(idx);
    }
    unreachable;
}

// inline for better error trace
pub inline fn mapToZigError(T: type, abi_err: ErrorSet(T)) T {
    @branchHint(.cold);
    inline for (@typeInfo(T).error_set.?, 0..) |field, idx| {
        if (idx == @intFromEnum(abi_err)) return @field(T, field.name);
    }
    if (@hasField(ErrorSet(T), "unexpected")) {
        return T.unexpected;
    } else {
        @trap();
    }
}

pub fn ErrorUnion(E: type, V: type) type {
    return extern struct {
        u: TaggedUnion(extern union {
            value: V,
            err: ErrorSet(E),
        }),

        pub fn wrap(eu: E!ZigType(V)) @This() {
            return if (eu) |v| .{ .u = .init(.value, abi.wrap(v)) } else |err| .{ .u = .init(.err, mapToAbiError(E, err)) };
        }

        // inline for better error trace
        pub inline fn unwrap(self: @This()) E!ZigType(V) {
            return switch (self.u.activeField()) {
                // avoid abi.unwrap so abi.unwrap can be inlined for better error traces
                .value => if (comptime hasDecl(V, "unwrap")) self.u.get(.value).unwrap() else self.u.get(.value),
                .err => mapToZigError(E, self.u.get(.err)),
            };
        }

        pub fn value(v: ZigType(V)) @This() {
            return .{ .u = .init(.value, abi.wrap(v)) };
        }

        pub fn throw(abi_err: ErrorSet(E)) @This() {
            return .{ .u = .init(.err, abi_err) };
        }
    };
}

pub fn Type(T: type) type {
    return switch (@typeInfo(T)) {
        .pointer => |ti| switch (ti.size) {
            .slice => Slice(if (ti.is_const) .immutable else .mutable, Type(ti.child)),
            .one, .many => T,
            .c => unreachable,
        },
        .error_union => |ti| ErrorUnion(ti.error_set, Type(ti.payload)),
        .error_set => ErrorSet(T),
        else => T,
    };
}

fn hasDecl(T: type, comptime name: []const u8) bool {
    return switch (@typeInfo(T)) {
        .@"struct", .@"enum", .@"union", .@"opaque" => @hasDecl(T, name),
        else => false,
    };
}

pub fn wrap(v: anytype) Type(@TypeOf(v)) {
    const T = Type(@TypeOf(v));
    return if (comptime hasDecl(T, "wrap")) T.wrap(v) else v;
}

pub fn ZigType(T: type) type {
    return if (comptime hasDecl(T, "unwrap")) @typeInfo(@TypeOf(T.unwrap)).@"fn".return_type.? else T;
}

// inline for better error trace
pub inline fn unwrap(v: anytype) ZigType(@TypeOf(v)) {
    return if (comptime hasDecl(@TypeOf(v), "unwrap")) v.unwrap() else v;
}
