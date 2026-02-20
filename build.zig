const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const api_mod = b.addModule("api", .{
        .root_source_file = b.path("src/api.zig"),
        .target = target,
        .optimize = optimize,
    });

    const libminecraft = b.addLibrary(.{
        .name = "minecraft",
        .linkage = .dynamic,
        // .version =
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/minecraft.zig"),
            .target = target,
            .optimize = optimize,
            .imports = &.{
                .{
                    .name = "api",
                    .module = api_mod,
                },
            },
        }),
    });

    b.installArtifact(libminecraft);

    _ = libminecraft.getEmittedH();
}
