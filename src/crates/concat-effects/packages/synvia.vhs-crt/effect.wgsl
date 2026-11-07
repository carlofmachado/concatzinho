struct Params { scanlines: f32, noise: f32, bleed: f32, distortion: f32, vignette: f32, desaturation: f32 }

// Adapted from Drift by CutWire Studios (GPL-3.0-or-later), effects/vhs_crt.

// One pixel of a 1080 line picture, in this layer's pixels: sizes given in
// pixels look the same at every resolution.
fn d_px() -> f32 {
    return max(frame.size.y / 1080.0, 0.25);
}

fn effect(uv: vec2<f32>) -> vec4<f32> {
    let px = d_px();
    let wave = sin(uv.y * 24.0 + frame.time * 3.0) * params.distortion * 0.01 * 14.0 * px / frame.size.x;
    let x = clamp(uv.x + wave, 0.0, 1.0);
    let bleed = params.bleed * px / frame.size.x;
    let src = sample(vec2<f32>(x, uv.y));
    var col = to_display(vec3<f32>(
        sample(vec2<f32>(clamp(x + bleed, 0.0, 1.0), uv.y)).r,
        src.g,
        sample(vec2<f32>(clamp(x - bleed, 0.0, 1.0), uv.y)).b));
    col = mix(col, vec3<f32>(dot(col, vec3<f32>(0.299, 0.587, 0.114))), params.desaturation * 0.01);
    // Every other line of a 1080 line picture, whatever this layer's size.
    let row = floor(uv.y * frame.size.y / max(px, 1.0));
    if (row - 2.0 * floor(row / 2.0) < 0.5) {
        col *= 1.0 - params.scanlines * 0.01 * 0.55;
    }
    let p = uv * 2.0 - vec2<f32>(1.0);
    col *= clamp(1.0 - params.vignette * 0.01 * dot(p, p) * 0.85, 0.0, 1.0);
    let n = hash(floor(uv * frame.size), floor(frame.time * 30.0)) * 2.0 - 1.0;
    let amp = params.noise * 0.01 * 42.0 / 255.0;
    col += vec3<f32>(n * amp, n * amp * 0.92, n * amp * 0.85);
    return vec4<f32>(from_display(col), src.a);
}
