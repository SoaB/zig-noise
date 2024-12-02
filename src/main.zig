const rl = @cImport({
    @cInclude("Raylib.h");
});

const std = @import("std");
const math = std.math;
const n = @import("noise.zig");

const scrWidth = 800;
const scrHeight = 600;

var canvas: rl.RenderTexture2D = undefined;
var pixels: [scrWidth * scrHeight * 4]u8 = undefined;
var gradient_colors: [256]rl.Color = undefined;
var noise: [scrWidth * scrHeight]f64 = undefined;

fn lerp(a: u8, b: u8, t: f32) u8 {
    const fa: f32 = @floatFromInt(a);
    const fb: f32 = @floatFromInt(b);
    const result: f32 = fa + (fb - fa) * t;
    return @as(u8, @intFromFloat(result));
}

fn colorLerp(c1: rl.Color, c2: rl.Color, t: f32) rl.Color {
    return rl.Color{
        .r = lerp(c1.r, c2.r, t),
        .g = lerp(c1.g, c2.g, t),
        .b = lerp(c1.b, c2.b, t),
        .a = 255,
    };
}

fn getGradient(c1: rl.Color, c2: rl.Color) void {
    for (0..256) |i| {
        const pct: f32 = @floatFromInt(i);
        gradient_colors[i] = colorLerp(c1, c2, pct / 255.0);
    }
}
fn getDualGradient(c1: rl.Color, c2: rl.Color, c3: rl.Color, c4: rl.Color) void {
    for (0..256) |i| {
        var pct: f32 = @floatFromInt(i);
        pct /= 255.0;
        if (pct < 0.5) {
            gradient_colors[i] = colorLerp(c1, c2, pct * 2.0);
        } else {
            gradient_colors[i] = colorLerp(c3, c4, pct * 1.5 - pct * 0.5);
        }
    }
}
fn clamp(min: usize, max: usize, v: usize) usize {
    var ret: usize = v;
    if (v < min) {
        ret = min;
    } else if (v > max) {
        ret = max;
    }
    return ret;
}
fn rescaleAndDraw(min: f64, max: f64) void {
    const scale = 255.0 / (max - min);
    const offset = min * scale;
    for (noise, 0..) |_, i| {
        noise[i] = noise[i] * scale - offset;
        const in: usize = @intFromFloat(noise[i]);
        const c = gradient_colors[clamp(0, 255, in)];
        const p = i * 4;
        pixels[p] = c.r;
        pixels[p + 1] = c.g;
        pixels[p + 2] = c.b;
        pixels[p + 3] = 255;
    }
}

fn turbulence(x: f64, y: f64, frequency: f64, lacunarity: f64, gain: f64, octaves: i32) f64 {
    var sum: f64 = 0.0;
    var amplitude: f64 = 1.0;
    var freq: f64 = frequency;
    for (0..@intCast(octaves)) |_| {
        var f = n.Noise2(x * frequency, y * frequency) * amplitude;
        if (f < 0) {
            f = -1.0 * f;
        }
        sum += f;
        freq = freq * lacunarity;
        amplitude = amplitude * gain;
    }
    return sum;
}

fn fbm2(x: f64, y: f64, frequency: f64, lacunarity: f64, gain: f64, octaves: i32) f64 {
    var sum: f64 = 0.0;
    var amplitude: f64 = 1.0;
    for (0..@intCast(octaves)) |_| {
        sum += n.Noise2(x * frequency, y * frequency) * amplitude;
        frequency = frequency * lacunarity;
        amplitude = amplitude * gain;
    }
    return sum;
}
fn makeNoise(frequency: f64, lacunarity: f64, gain: f64, octaves: i32) void {
    var i: usize = 0;
    var min: f64 = 9999.0;
    var max: f64 = -9999.0;
    for (0..scrHeight) |y| {
        for (0..scrWidth) |x| {
            const fx: f64 = @floatFromInt(x);
            const fy: f64 = @floatFromInt(y);
            noise[i] = turbulence(fx, fy, frequency, lacunarity, gain, octaves);
            if (noise[i] < min) {
                min = noise[i];
            } else if (noise[i] > max) {
                max = noise[i];
            }
            i += 1;
        }
    }
    getDualGradient(rl.Color{ .r = 255, .g = 0, .b = 0, .a = 255 }, rl.Color{ .r = 255, .g = 242, .b = 0, .a = 255 }, rl.Color{ .r = 0, .g = 255, .b = 0, .a = 255 }, rl.Color{ .r = 255, .g = 255, .b = 0, .a = 255 });
    rescaleAndDraw(min, max);
}

pub fn updatePixels() void {
    // comvert to c void * from zig ptr
    const p: ?*const anyopaque = @as(?*const anyopaque, @ptrCast(@alignCast(&pixels)));
    rl.UpdateTexture(canvas.texture, p);
}
pub fn mkNoise(gg: f32) void {
    makeNoise(0.01 * gg, 2.0, 0.5, 6);
    updatePixels();
}
pub fn main() !void {
    // random ..............................................
    var prng = std.Random.DefaultPrng.init(blk: {
        var seed: u64 = undefined;
        try std.posix.getrandom(std.mem.asBytes(&seed));
        break :blk seed;
    });
    const rand = prng.random();
    // ......................................................
    rl.InitWindow(scrWidth, scrHeight, "Noise for FUN");
    rl.SetTargetFPS(60);
    canvas = rl.LoadRenderTexture(scrWidth, scrHeight);
    var cnt: f32 = 0;
    mkNoise(rand.float(f32));
    while (!rl.WindowShouldClose()) {
        cnt += 1;
        if (cnt > 6) {
            mkNoise(rand.float(f32));
            cnt = 0;
        }
        rl.BeginDrawing();
        rl.ClearBackground(rl.BLACK);
        rl.DrawTexture(canvas.texture, 0, 0, rl.WHITE);
        rl.EndDrawing();
    }
    rl.UnloadRenderTexture(canvas);
    rl.CloseWindow();
}
