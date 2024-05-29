const sdl = @cImport({
    @cInclude("SDL.h");
    @cInclude("SDL_render.h");
});

const std = @import("std");
const assert = @import("std").debug.assert;

pub fn main() !void {
    if (sdl.SDL_Init(sdl.SDL_INIT_VIDEO) != 0) {
        sdl.SDL_Log("Unable to initialize SDL: %s", sdl.SDL_GetError());
        return error.SDLInitializationFailed;
    }
    defer sdl.SDL_Quit();

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

    mainloop: while (true) {
        var event: sdl.SDL_Event = undefined;
        while (sdl.SDL_PollEvent(&event) != 0) {
            switch (event.type) {
                sdl.SDL_QUIT => break :mainloop,
                else => {},
            }
        }

        _ = sdl.SDL_SetRenderDrawColor(renderer, 0, 255, 0, 255);
        _ = sdl.SDL_RenderClear(renderer);

        const rect = sdl.SDL_Rect{
            .x = 100,
            .y = 100,
            .w = 200,
            .h = 100,
        };
        _ = sdl.SDL_SetRenderDrawColor(renderer, 255, 255, 0, 255);
        _ = sdl.SDL_RenderFillRect(renderer, &rect);

        sdl.SDL_RenderPresent(renderer);
        sdl.SDL_Delay(17);
    }
}
