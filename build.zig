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
        const sdl_path = "libs/SDL2-2.30.3/";
        exe.addIncludePath(.{ .path = sdl_path ++ "include" });
        exe.addObjectFile(.{ .path = sdl_path ++ "lib/x64/SDL2.lib" });

        b.installBinFile(sdl_path ++ "lib/x64/SDL2.dll", "SDL2.dll");
        exe.addLibraryPath(.{ .path = sdl_path ++ "lib/x64" });
        exe.linkSystemLibrary("SDL2");
    }
    { // OpenGL
        exe.addIncludePath(.{ .path = "C:/Program Files (x86)/Windows Kits/10/Include/10.0.26100.0/um/gl" });
        exe.addObjectFile(.{ .path = "C:/Program Files (x86)/Windows Kits/10/Lib/10.0.26100.0/um/x64/OpenGL32.lib" });
    }
    { // GLEW
        const glew_path = "libs/glew-2.2.0/";
        exe.addIncludePath(.{ .path = glew_path ++ "include/GL" });
        exe.addObjectFile(.{ .path = glew_path ++ "lib/Release/x64/glew32.lib" });
        //   exe.addObjectFile(.{ .path = glew_path ++ "lib/Release/x64/glew32s.lib" });

        b.installBinFile(glew_path ++ "bin/Release/x64/glew32.dll", "glew32.dll");
        exe.addLibraryPath(.{ .path = glew_path ++ "lib/Release/x64/" });
        exe.linkSystemLibrary("glew32");
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
