const sdl = @cImport({
    @cInclude("SDL.h");
    @cInclude("SDL_render.h");
    @cInclude("SDL_video.h");
    @cInclude("SDL_opengl.h");
});
const gl = @cImport({
    @cInclude("glew.h");
    @cInclude("Windows.h");
    @cInclude("gl.h");
});

const std = @import("std");
const assert = @import("std").debug.assert;

pub fn main() !void {
    if (sdl.SDL_Init(sdl.SDL_INIT_VIDEO) != 0) {
        sdl.SDL_Log("Unable to initialize SDL: %s", sdl.SDL_GetError());
        return error.SDLInitializationFailed;
    }
    defer sdl.SDL_Quit();

    _ = sdl.SDL_GL_SetAttribute(sdl.SDL_GL_DOUBLEBUFFER, 1);
    _ = sdl.SDL_GL_SetAttribute(sdl.SDL_GL_ACCELERATED_VISUAL, 1);
    _ = sdl.SDL_GL_SetAttribute(sdl.SDL_GL_RED_SIZE, 8);
    _ = sdl.SDL_GL_SetAttribute(sdl.SDL_GL_GREEN_SIZE, 8);
    _ = sdl.SDL_GL_SetAttribute(sdl.SDL_GL_BLUE_SIZE, 8);
    _ = sdl.SDL_GL_SetAttribute(sdl.SDL_GL_ALPHA_SIZE, 8);
    _ = sdl.SDL_GL_SetAttribute(sdl.SDL_GL_CONTEXT_MAJOR_VERSION, 4);
    _ = sdl.SDL_GL_SetAttribute(sdl.SDL_GL_CONTEXT_MINOR_VERSION, 6);
    _ = sdl.SDL_GL_SetAttribute(sdl.SDL_GL_CONTEXT_PROFILE_MASK, sdl.SDL_GL_CONTEXT_PROFILE_CORE);

    const window_flags = sdl.SDL_WINDOW_RESIZABLE | sdl.SDL_WINDOW_OPENGL;
    const window = sdl.SDL_CreateWindow("Window", sdl.SDL_WINDOWPOS_UNDEFINED, sdl.SDL_WINDOWPOS_UNDEFINED, 800, 600, window_flags) orelse {
        sdl.SDL_Log("Unable to create window: %s", sdl.SDL_GetError());
        return error.SDLInitializationFailed;
    };
    defer sdl.SDL_DestroyWindow(window);

    const renderer = sdl.SDL_CreateRenderer(window, -1, 0) orelse {
        sdl.SDL_Log("Unable to create renderer: %s", sdl.SDL_GetError());
        return error.SDLInitializationFailed;
    };
    defer sdl.SDL_DestroyRenderer(renderer);

    const gl_context = sdl.SDL_GL_CreateContext(window) orelse {
        sdl.SDL_Log("Unable to create OpenGL context: %s", sdl.SDL_GetError());
        return error.SDLInitializationFailed;
    };
    defer sdl.SDL_GL_DeleteContext(gl_context);

    _ = sdl.SDL_GL_MakeCurrent(window, gl_context);
    if (gl.glewInit() != gl.GLEW_OK) {
        sdl.SDL_Log("Unable to initialize GLEW");
        return error.SDLInitializationFailed;
    }

    { // Print OpenGL version and profile
        const version = gl.glGetString(gl.GL_VERSION);
        std.debug.print("OpenGL version: {s}\n", .{version});

        var contextProfile: c_int = undefined;
        gl.glGetIntegerv(gl.GL_CONTEXT_PROFILE_MASK, &contextProfile);
        if ((contextProfile & gl.GL_CONTEXT_CORE_PROFILE_BIT) != 0) {
            std.debug.print("Core profile\n", .{});
        } else {
            std.debug.print("Not a core profile\n", .{});
        }
    }

    var tex_id: c_uint = undefined;
    _ = gl.__glewCreateTextures.?(gl.GL_TEXTURE_2D, 1, &tex_id);
    std.debug.print("Texture ID: {d}\n", .{tex_id});

    mainloop: while (true) {
        var event: sdl.SDL_Event = undefined;
        while (sdl.SDL_PollEvent(&event) != 0) {
            switch (event.type) {
                sdl.SDL_QUIT => break :mainloop,
                else => {},
            }
        }

        gl.glViewport(0, 0, 800, 600);
        gl.glClearColor(0.1, 0.05, 0.1, 1.01);
        gl.glClear(gl.GL_COLOR_BUFFER_BIT);

        sdl.SDL_GL_SwapWindow(window);

        sdl.SDL_Delay(17);
    }
}
