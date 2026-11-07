struct Params { amount: f32, detail: f32, contrast: f32 }

// Adapted from Drift by CutWire Studios (GPL-3.0-or-later), effects/sketch_pencil.

// One pixel of a 1080 line picture, in this layer's pixels: sizes given in
// pixels look the same at every resolution.
fn d_px() -> f32 {
    return max(frame.size.y / 1080.0, 0.25);
}

fn effect(uv: vec2<f32>) -> vec4<f32> {
    let src = sample(uv);
    let t = vec2<f32>(d_px()) / frame.size;
    let r = mix(1.0, 3.0, params.detail * 0.01);
    var blur = vec3<f32>(0.0);
    for (var x = -2; x <= 2; x++) {
        for (var y = -2; y <= 2; y++) {
            blur += to_display(sample(uv + vec2<f32>(f32(x), f32(y)) * t * r).rgb);
        }
    }
    blur = blur / 25.0;
    // A colour dodge of the picture by its own blur: flat areas go to paper,
    // edges and texture stay as graphite.
    let dodge = clamp(luma(to_display(src.rgb)) / max(luma(blur), 1e-3), 0.0, 1.0);
    let tl = luma(to_display(sample(uv + vec2<f32>(-t.x, -t.y) * 2.0).rgb));
    let tr = luma(to_display(sample(uv + vec2<f32>(t.x, -t.y) * 2.0).rgb));
    let bl = luma(to_display(sample(uv + vec2<f32>(-t.x, t.y) * 2.0).rgb));
    let br = luma(to_display(sample(uv + vec2<f32>(t.x, t.y) * 2.0).rgb));
    let edge = abs(tl - br) + abs(tr - bl);
    let k = params.contrast * 0.01;
    let shade = clamp(pow(dodge, mix(1.0, 4.0, k)) - edge * mix(1.0, 3.0, k), 0.0, 1.0);
    let sketch = mix(vec3<f32>(0.08), vec3<f32>(0.95), shade);
    return vec4<f32>(from_display(mix(to_display(src.rgb), sketch, params.amount * 0.01)), src.a);
}
