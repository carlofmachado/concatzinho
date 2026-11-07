struct Params { amount: f32, frequency: f32, rgb: f32, blocks: f32, flash: f32, seed: f32 }

// Adapted from Drift by CutWire Studios (GPL-3.0-or-later), effects/digital_glitch.

// One pixel of a 1080 line picture, in this layer's pixels: sizes given in
// pixels look the same at every resolution.
fn d_px() -> f32 {
    return max(frame.size.y / 1080.0, 0.25);
}

fn effect(uv: vec2<f32>) -> vec4<f32> {
    let px = d_px();
    let k = params.amount * 0.01;
    let f = params.frequency * 0.01;
    let t = floor(frame.time * 30.0) + params.seed * 1000.0;
    let pix = floor(uv * frame.size);
    let block = floor(pix / (24.0 * px));
    var sx = uv.x;
    if (hash(block, t) <= f) {
        sx -= (hash(block, t + 0.5) * 2.0 - 1.0) * 40.0 * k * params.blocks * 0.01 * k * px / frame.size.x;
    }
    sx -= (hash(vec2<f32>(pix.y, 1.0), t) * 2.0 - 1.0) * f * k * 0.75 * 40.0 * px / frame.size.x;
    var sy = uv.y;
    let jump = hash(vec2<f32>(11.0, 5.0), t) < f * 0.2;
    if (jump) {
        sy -= (hash(vec2<f32>(11.0, 5.0), t + 0.5) * 14.0 - 7.0) * px / frame.size.y;
    }
    let ang = hash(vec2<f32>(3.0, 3.0), t) * 6.2831853;
    let delta = vec2<f32>(cos(ang), sin(ang)) * params.rgb * k * px / frame.size;
    let at = clamp(vec2<f32>(sx, sy), vec2<f32>(0.0), vec2<f32>(1.0));
    let src = sample(at);
    var rgb = to_display(vec3<f32>(sample(clamp(at + delta, vec2<f32>(0.0), vec2<f32>(1.0))).r, src.g,
        sample(clamp(at - delta, vec2<f32>(0.0), vec2<f32>(1.0))).b));
    let n = hash(pix, t) * 2.0 - 1.0;
    let amp = f * k * 0.5 * 36.0 / 255.0;
    rgb += vec3<f32>(n * amp, n * amp * 0.92, n * amp * 0.85);
    let fl = params.flash * 0.01 * k;
    if (hash(vec2<f32>(7.0, 3.0), t) < fl) {
        rgb += (vec3<f32>(1.0) - rgb) * hash(vec2<f32>(7.0, 3.0), t + 0.5) * fl;
    }
    return vec4<f32>(from_display(rgb), src.a);
}
