struct Params { amount: f32, radius: f32 }

// Adapted from Drift by CutWire Studios (GPL-3.0-or-later), effects/oil_paint.

// One pixel of a 1080 line picture, in this layer's pixels: sizes given in
// pixels look the same at every resolution.
fn d_px() -> f32 {
    return max(frame.size.y / 1080.0, 0.25);
}

fn effect(uv: vec2<f32>) -> vec4<f32> {
    let src = sample(uv);
    let r = i32(clamp(floor(params.radius + 0.5), 1.0, 8.0));
    let t = vec2<f32>(d_px()) / frame.size;
    var mean = vec3<f32>(0.0);
    var m2 = vec3<f32>(0.0);
    var count = 0.0;
    for (var y = -8; y <= 8; y++) {
        for (var x = -8; x <= 8; x++) {
            if (abs(x) > r || abs(y) > r) {
                continue;
            }
            let c = to_display(sample(uv + vec2<f32>(f32(x), f32(y)) * t).rgb);
            mean += c;
            m2 += c * c;
            count += 1.0;
        }
    }
    mean = mean / count;
    let spread = max(m2 / count - mean * mean, vec3<f32>(0.0));
    let d = to_display(src.rgb);
    let flat_c = mean / max(luma(mean), 1e-4) * luma(d);
    let w = 1.0 / (1.0 + dot(spread, vec3<f32>(1.0)));
    let painted = mix(mean, flat_c, w);
    return vec4<f32>(from_display(mix(d, painted, params.amount * 0.01)), src.a);
}
