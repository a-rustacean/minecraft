const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const api_mod = b.addModule("api", .{
        .root_source_file = b.path("src/api.zig"),
        .target = target,
        .optimize = optimize,
    });

    const libminecraft_mod = b.createModule(.{
        .root_source_file = b.path("src/minecraft/lib.zig"),
        .target = target,
        .optimize = optimize,
        .imports = &.{
            .{
                .name = "api",
                .module = api_mod,
            },
        },
    });

    const libminecraft = b.addLibrary(.{
        .name = "minecraft",
        .linkage = .dynamic,
        .root_module = libminecraft_mod,
    });

    const minecraft_mod = b.addModule("minecraft", .{
        .root_source_file = b.path("src/minecraft/mod.zig"),
        .target = target,
        .optimize = optimize,
        .imports = &.{
            .{
                .name = "api",
                .module = api_mod,
            },
        },
    });

    const liblucky_block = b.addLibrary(.{
        .name = "lucky_block",
        .linkage = .dynamic,
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/lucky_block/lib.zig"),
            .target = target,
            .optimize = optimize,
            .imports = &.{
                .{
                    .name = "api",
                    .module = api_mod,
                },
                .{
                    .name = "minecraft",
                    .module = minecraft_mod,
                },
            },
        }),
    });

    b.installArtifact(libminecraft);
    b.installArtifact(liblucky_block);

    const api_tests = b.addTest(.{ .root_module = api_mod });
    const minecraft_tests = b.addTest(.{ .root_module = libminecraft_mod });

    const run_api_tests = b.addRunArtifact(api_tests);
    const run_minecraft_tests = b.addRunArtifact(minecraft_tests);

    const test_step = b.step("test", "Run all unit tests");
    test_step.dependOn(&run_api_tests.step);
    test_step.dependOn(&run_minecraft_tests.step);
}
