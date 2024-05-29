const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const exe = b.addExecutable(.{
        .name = "zig-playground",
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    exe.linkLibC();

    { // SDL2
        const sdl_path = "libs\\SDL2-2.30.3\\";
        exe.addIncludePath(.{ .path = sdl_path ++ "include\\" });
        exe.addLibraryPath(.{ .path = sdl_path ++ "lib\\x64\\" });
        exe.addObjectFile(.{ .path = sdl_path ++ "lib\\x64\\SDL2.lib" });

        // b.installBinFile(sdl_path ++ "lib\\x64\\SDL2.dll", "SDL2.dll");
        // exe.linkSystemLibrary("SDL2");
    }

    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }
    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);
}
