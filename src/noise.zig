fn FASTFLOOR(x: f64) i32 {
    if (x > 0) {
        return @as(i32, @intFromFloat(x));
    }
    return @as(i32, @intFromFloat(x)) - 1;
}
const perm: [512]u8 = [512]u8{
    151, 160, 137, 91,  90,  15,
    131, 13,  201, 95,  96,  53,
    194, 233, 7,   225, 140, 36,
    103, 30,  69,  142, 8,   99,
    37,  240, 21,  10,  23,  190,
    6,   148, 247, 120, 234, 75,
    0,   26,  197, 62,  94,  252,
    219, 203, 117, 35,  11,  32,
    57,  177, 33,  88,  237, 149,
    56,  87,  174, 20,  125, 136,
    171, 168, 68,  175, 74,  165,
    71,  134, 139, 48,  27,  166,
    77,  146, 158, 231, 83,  111,
    229, 122, 60,  211, 133, 230,
    220, 105, 92,  41,  55,  46,
    245, 40,  244, 102, 143, 54,
    65,  25,  63,  161, 1,   216,
    80,  73,  209, 76,  132, 187,
    208, 89,  18,  169, 200, 196,
    135, 130, 116, 188, 159, 86,
    164, 100, 109, 198, 173, 186,
    3,   64,  52,  217, 226, 250,
    124, 123, 5,   202, 38,  147,
    118, 126, 255, 82,  85,  212,
    207, 206, 59,  227, 47,  16,
    58,  17,  182, 189, 28,  42,
    223, 183, 170, 213, 119, 248,
    152, 2,   44,  154, 163, 70,
    221, 153, 101, 155, 167, 43,
    172, 9,   129, 22,  39,  253,
    19,  98,  108, 110, 79,  113,
    224, 232, 178, 185, 112, 104,
    218, 246, 97,  228, 251, 34,
    242, 193, 238, 210, 144, 12,
    191, 179, 162, 241, 81,  51,
    145, 235, 249, 14,  239, 107,
    49,  192, 214, 31,  181, 199,
    106, 157, 184, 84,  204, 176,
    115, 121, 50,  45,  127, 4,
    150, 254, 138, 236, 205, 93,
    222, 114, 67,  29,  24,  72,
    243, 141, 128, 195, 78,  66,
    215, 61,  156, 180, 151, 160,
    137, 91,  90,  15,  131, 13,
    201, 95,  96,  53,  194, 233,
    7,   225, 140, 36,  103, 30,
    69,  142, 8,   99,  37,  240,
    21,  10,  23,  190, 6,   148,
    247, 120, 234, 75,  0,   26,
    197, 62,  94,  252, 219, 203,
    117, 35,  11,  32,  57,  177,
    33,  88,  237, 149, 56,  87,
    174, 20,  125, 136, 171, 168,
    68,  175, 74,  165, 71,  134,
    139, 48,  27,  166, 77,  146,
    158, 231, 83,  111, 229, 122,
    60,  211, 133, 230, 220, 105,
    92,  41,  55,  46,  245, 40,
    244, 102, 143, 54,  65,  25,
    63,  161, 1,   216, 80,  73,
    209, 76,  132, 187, 208, 89,
    18,  169, 200, 196, 135, 130,
    116, 188, 159, 86,  164, 100,
    109, 198, 173, 186, 3,   64,
    52,  217, 226, 250, 124, 123,
    5,   202, 38,  147, 118, 126,
    255, 82,  85,  212, 207, 206,
    59,  227, 47,  16,  58,  17,
    182, 189, 28,  42,  223, 183,
    170, 213, 119, 248, 152, 2,
    44,  154, 163, 70,  221, 153,
    101, 155, 167, 43,  172, 9,
    129, 22,  39,  253, 19,  98,
    108, 110, 79,  113, 224, 232,
    178, 185, 112, 104, 218, 246,
    97,  228, 251, 34,  242, 193,
    238, 210, 144, 12,  191, 179,
    162, 241, 81,  51,  145, 235,
    249, 14,  239, 107, 49,  192,
    214, 31,  181, 199, 106, 157,
    184, 84,  204, 176, 115, 121,
    50,  45,  127, 4,   150, 254,
    138, 236, 205, 93,  222, 114,
    67,  29,  24,  72,  243, 141,
    128, 195, 78,  66,  215, 61,
    156, 180,
};

fn Q(cond: bool, v1: f64, v2: f64) f64 {
    if (cond) {
        return v1;
    }
    return v2;
}

fn grad1(hash: u8, x: f64) f64 {
    const h = hash & 15;
    var grad = @as(f64, @floatFromInt(1 + h & 7));
    if (h & 8 != 0) {
        grad = -grad;
    }
    return grad * x;
}

fn grad2(hash: u8, x: f64, y: f64) f64 {
    const h = hash & 7;
    const u = Q(h < 4, x, y);
    const v = Q(h < 4, y, x);
    return Q(h & 1 != 0, -u, u) + Q(h & 2 != 0, -2 * v, 2 * v);
}

fn grad3(hash: u8, x: f64, y: f64, z: f64) f64 {
    const h = hash & 15;
    const u = Q(h < 8, x, y);
    const t = Q(h == 12 or h == 14, x, z);
    const v = Q(h < 4, y, t);
    return Q(h & 1 != 0, -u, u) + Q(h & 2 != 0, -v, v);
}

/// 1D simplex noise
pub fn Noise1(x: f64) f64 {
    const gi0 = FASTFLOOR(x);
    const gi1 = gi0 + 1;
    const x0 = x - @as(f64, @floatFromInt(gi0));
    const x1 = x0 - 1;

    var t0 = 1 - x0 * x0;
    t0 *= t0;
    const n0 = t0 * t0 * grad1(perm[@intCast(gi0 & 0xff)], x0);

    var t1 = 1 - x1 * x1;
    t1 *= t1;
    const n1 = t1 * t1 * grad1(perm[@intCast(gi1 & 0xff)], x1);
    // The maximum value of this noise is 8*(3/4)^4 = 2.53125
    // A factor of 0.395 would scale to fit exactly within [-1,1].
    // fmt.Printf("Noise1 x %.4f, i0 %v, i1 %v, x0 %.4f, x1 %.4f, perm0 %d, perm1 %d: %.4f,%.4f\n", x, i0, i1, x0, x1, perm[i0&0xff], perm[i1&0xff], n0, n1)
    // The algorithm isn't perfect, as it is assymetric. The correction will normalize the result to the interval [-1,1], but the average will be off by 3%.
    return (n0 + n1 + 0.076368899) / 2.45488110001;
}

// 2D simplex noise
pub fn Noise2(x: f64, y: f64) f64 {
    const F2 = 0.366025403;
    const G2 = 0.211324865;

    var n0: f64 = 0.9;
    var n1: f64 = 0.0;
    var n2: f64 = 0.0;

    // Skew the input space to determine which simplex cell we're in
    const s = (x + y) * F2;
    const xs = x + s;
    const ys = y + s;
    const i = FASTFLOOR(xs);
    const j = FASTFLOOR(ys);

    const t = @as(f64, @floatFromInt(i + j)) * G2;
    const X0 = @as(f64, @floatFromInt(i)) - t;
    const Y0 = @as(f64, @floatFromInt(j)) - t;
    const x0 = x - X0;
    const y0 = y - Y0;

    var gi1: i32 = 0;
    var j1: i32 = 0;

    if (x0 > y0) {
        gi1 = 1;
        j1 = 0;
    } else {
        gi1 = 0;
        j1 = 1;
    }
    const x1 = x0 - @as(f64, @floatFromInt(gi1)) + G2;
    const y1 = y0 - @as(f64, @floatFromInt(j1)) + G2;
    const x2 = x0 - 1 + 2 * G2;
    const y2 = y0 - 1 + 2 * G2;
    const ii = i & 0xff;
    const jj = j & 0xff;
    var t0 = 0.5 - x0 * x0 - y0 * y0;
    if (t0 < 0) {
        n0 = 0;
    } else {
        t0 *= t0;
        n0 = t0 * t0 * grad2(perm[@intCast(ii + @as(i32, perm[@intCast(jj)]))], x0, y0);
    }
    var t1 = 0.5 - x1 * x1 - y1 * y1;
    if (t1 < 0) {
        n1 = 0;
    } else {
        t1 *= t1;
        n1 = t1 * t1 * grad2(perm[@intCast(ii + gi1 + @as(i32, perm[@intCast(jj + j1)]))], x1, y1);
    }
    var t2 = 0.5 - x2 * x2 - y2 * y2;
    if (t2 < 0) {
        n2 = 0;
    } else {
        t2 *= t2;
        n2 = t2 * t2 * grad2(perm[@intCast(ii + 1 + @as(i32, perm[@intCast(jj + 1)]))], x2, y2);
    }
    return (n0 + n1 + n2) / 0.022108854818853867;
}

// 3D simplex noise
pub fn Noise3(x: f64, y: f64, z: f64) f64 {
    const F3 = 0.333333333;
    const G3 = 0.166666667;
    var n0: f64 = 0.0;
    var n1: f64 = 0.0;
    var n2: f64 = 0.0;
    var n3: f64 = 0.0;

    // Skew the input space to determine which simplex cell we're in
    const s = (x + y + z) * F3;
    const xs = x + s;
    const ys = y + s;
    const zs = z + s;
    const i = FASTFLOOR(xs);
    const j = FASTFLOOR(ys);
    const k = FASTFLOOR(zs);

    const t = @as(f64, @floatFromInt(i + j + k)) * G3;
    const X0 = @as(f64, @floatFromInt(i)) - t;
    const Y0 = @as(f64, @floatFromInt(j)) - t;
    const Z0 = @as(f64, @floatFromInt(k)) - t;
    const x0 = x - X0;
    const y0 = y - Y0;
    const z0 = z - Z0;
    var gi1: i32 = 0;
    var j1: i32 = 0;
    var k1: i32 = 0;
    var gi2: i32 = 0;
    var j2: i32 = 0;
    var k2: i32 = 0;

    if (x0 >= y0) {
        if (y0 >= z0) {
            gi1 = 1;
            j1 = 0;
            k1 = 0;
            gi2 = 1;
            j2 = 1;
            k2 = 0;
        } else if (x0 >= z0) {
            gi1 = 1;
            j1 = 0;
            k1 = 0;
            gi2 = 1;
            j2 = 0;
            k2 = 1;
        } else {
            gi1 = 0;
            j1 = 0;
            k1 = 1;
            gi2 = 1;
            j2 = 0;
            k2 = 1;
        }
    } else { // x0<y0
        if (y0 < z0) {
            gi1 = 0;
            j1 = 0;
            k1 = 1;
            gi2 = 0;
            j2 = 1;
            k2 = 1;
        } else if (x0 < z0) {
            gi1 = 0;
            j1 = 1;
            k1 = 0;
            gi2 = 0;
            j2 = 1;
            k2 = 1;
        } else {
            gi1 = 0;
            j1 = 1;
            k1 = 0;
            gi2 = 1;
            j2 = 1;
            k2 = 0;
        }
    }
    const x1 = x0 - @as(f64, @floatFromInt(gi1)) + G3;
    const y1 = y0 - @as(f64, @floatFromInt(j1)) + G3;
    const z1 = z0 - @as(f64, @floatFromInt(k1)) + G3;
    const x2 = x0 - @as(f64, @floatFromInt(gi2)) + 2 * G3;
    const y2 = y0 - @as(f64, @floatFromInt(j2)) + 2 * G3;
    const z2 = z0 - @as(f64, @floatFromInt(k2)) + 2 * G3;
    const x3 = x0 - 1 + 3 * G3;
    const y3 = y0 - 1 + 3 * G3;
    const z3 = z0 - 1 + 3 * G3;
    const ii = i & 0xff;
    const jj = j & 0xff;
    const kk = k & 0xff;
    var t0 = 0.6 - x0 * x0 - y0 * y0 - z0 * z0;
    if (t0 < 0) {
        n0 = 0;
    } else {
        t0 *= t0;
        n0 = t0 * t0 * grad3(perm[@intCast(ii + @as(i32, perm[@intCast(jj + @as(i32, perm[@intCast(kk)]))]))], x0, y0, z0);
    }
    var t1 = 0.6 - x1 * x1 - y1 * y1 - z1 * z1;
    if (t1 < 0) {
        n1 = 0;
    } else {
        t1 *= t1;
        n1 = t1 * t1 * grad3(perm[@intCast(ii + gi1 + @as(i32, perm[@intCast(jj + j1 + @as(i32, perm[@intCast(kk + k1)]))]))], x1, y1, z1);
    }
    var t2 = 0.6 - x2 * x2 - y2 * y2 - z2 * z2;
    if (t2 < 0) {
        n2 = 0;
    } else {
        t2 *= t2;
        n2 = t2 * t2 * grad3(perm[@intCast(ii + gi2 + @as(i32, perm[@intCast(jj + j2 + @as(i32, perm[@intCast(kk + k2)]))]))], x2, y2, z2);
    }
    var t3 = 0.6 - x3 * x3 - y3 * y3 - z3 * z3;
    if (t3 < 0) {
        n3 = 0;
    } else {
        t3 *= t3;
        n3 = t3 * t3 * grad3(perm[@intCast(ii + 1 + @as(i32, perm[@intCast(jj + 1 + @as(i32, perm[@intCast(kk + 1)]))]))], x3, y3, z3);
    }
    return (n0 + n1 + n2 + n3) / 0.030555466710745972;
}
