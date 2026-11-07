struct Params { softness: f32, highlights: f32 }

// Adapted from Drift by CutWire Studios (GPL-3.0-or-later), transitions/luma_fade.

fn transition(uv: vec2<f32>, progress: f32) -> vec4<f32> {
    let a = from_at(uv);
    let b = to_at(uv);
    let s = params.softness * 0.01;
    var l = clamp(luma(to_display(a.rgb)), 0.0, 1.0);
    if (params.highlights > 0.5) {
        l = 1.0 - l;
    }
    // The threshold sweeps past the whole range, so the cut starts and ends clean.
    let th = mix(-s, 1.0 + s, progress);
    let m = 1.0 - smoothstep(th, th + s, l);
    return mix(a, b, clamp(m, 0.0, 1.0));
}
