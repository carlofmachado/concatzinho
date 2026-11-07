struct Params { jitter: f32, lines: f32, shift: f32, speed: f32 }

// Adapted from Drift by CutWire Studios (GPL-3.0-or-later), effects/scanline_glitch.

// One pixel of a 1080 line picture, in this layer's pixels: sizes given in
// pixels look the same at every resolution.
fn d_px() -> f32 {
    return max(frame.size.y / 1080.0, 0.25);
}

fn effect(uv: vec2<f32>) -> vec4<f32> {
    let px = d_px();
    let rows = frame.size.y / max(px, 1.0);
    let y = floor(uv.y * rows);
    let t = floor(frame.time * 12.0 * max(params.speed, 0.001));
    let jitter = params.jitter * 0.01;
    let jn = hash(vec2<f32>(y, 1.0), t);
    let tear = hash(vec2<f32>(y, 2.0), t);
    var sy = y;
    if (tear < jitter * 0.2) {
        sy = clamp(y + floor((tear * 2.0 - 0.5) * jitter * 6.0), 0.0, rows - 1.0);
    }
    let off = (jn * 2.0 - 1.0) * jitter * 40.0 * px / frame.size.x;
    let sx = clamp(uv.x - off, 0.0, 1.0);
    let v = (sy + 0.5) / rows;
    let s = params.shift * px / frame.size.x;
    let src = sample(vec2<f32>(sx, v));
    var col = to_display(vec3<f32>(sample(vec2<f32>(clamp(sx + s, 0.0, 1.0), v)).r, src.g,
        sample(vec2<f32>(clamp(sx - s, 0.0, 1.0), v)).b));
    if (y - 2.0 * floor(y / 2.0) < 0.5) {
        col *= 1.0 - params.lines * 0.01 * 0.55;
    }
    return vec4<f32>(from_display(col), src.a);
}
