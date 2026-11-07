struct Params { amount: f32, radius: f32, threshold: f32, softness: f32 }

// Adapted from Drift by CutWire Studios (GPL-3.0-or-later), effects/bokeh_dream.

// One pixel of a 1080 line picture, in this layer's pixels: sizes given in
// pixels look the same at every resolution.
fn d_px() -> f32 {
    return max(frame.size.y / 1080.0, 0.25);
}

fn effect(uv: vec2<f32>) -> vec4<f32> {
    let src = sample(uv);
    let r = params.radius * d_px() / frame.size;
    let th = params.threshold * 0.01;
    let knee = mix(0.05, 0.35, params.softness * 0.01);
    var acc = vec3<f32>(0.0);
    var wsum = 0.0;
    for (var i = 0; i < 16; i++) {
        let ang = 6.2831853 * f32(i) / 16.0;
        let ring = f32((i % 4) + 1) / 4.0;
        let s = sample(clamp(uv + vec2<f32>(cos(ang), sin(ang)) * r * ring, vec2<f32>(0.0), vec2<f32>(1.0))).rgb;
        var w = smoothstep(th, th + knee, luma(to_display(s)));
        w *= 1.0 - ring * 0.15;
        acc += s * w;
        wsum += w;
    }
    var bokeh = src.rgb;
    if (wsum > 1e-4) {
        bokeh = acc / wsum;
    }
    return vec4<f32>(mix(src.rgb, bokeh, params.amount * 0.01), src.a);
}
