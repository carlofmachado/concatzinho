struct Params { amount: f32, size: f32, shift: f32, frequency: f32, seed: f32 }

// Adapted from Drift by CutWire Studios (GPL-3.0-or-later), effects/block_glitch.

// One pixel of a 1080 line picture, in this layer's pixels: sizes given in
// pixels look the same at every resolution.
fn d_px() -> f32 {
    return max(frame.size.y / 1080.0, 0.25);
}

fn effect(uv: vec2<f32>) -> vec4<f32> {
    let px = d_px();
    let t = floor(frame.time * 30.0) + params.seed * 1000.0;
    let cell = floor(uv * frame.size / (params.size * px));
    if (hash(cell, t) > params.frequency * 0.01) {
        return sample(uv);
    }
    let shift = (hash(cell, t + 0.5) * 2.0 - 1.0) * params.shift * params.amount * 0.01 * px / frame.size.x;
    return sample(vec2<f32>(clamp(uv.x - shift, 0.0, 1.0), uv.y));
}
