struct Params { amount: f32, cx: f32, cy: f32, samples: f32 }

// Adapted from Drift by CutWire Studios (GPL-3.0-or-later), effects/spin_blur.

fn d_aspect() -> f32 {
    return frame.size.x / max(frame.size.y, 1.0);
}

fn effect(uv: vec2<f32>) -> vec4<f32> {
    let aspect = d_aspect();
    let c = vec2<f32>(params.cx, params.cy) * 0.01;
    let d = (uv - c) * vec2<f32>(aspect, 1.0);
    let n = i32(clamp(floor(params.samples + 0.5), 4.0, 24.0));
    let span = params.amount * 0.01 * 0.35;
    var acc = vec4<f32>(0.0);
    var wsum = 0.0;
    for (var i = 0; i < 24; i++) {
        if (i >= n) {
            break;
        }
        let t = (f32(i) / f32(n - 1) - 0.5) * 2.0;
        let ang = t * span;
        let q = vec2<f32>(d.x * cos(ang) - d.y * sin(ang), d.x * sin(ang) + d.y * cos(ang));
        let w = 1.0 - abs(t) * 0.5;
        acc += sample(clamp(c + q / vec2<f32>(aspect, 1.0), vec2<f32>(0.0), vec2<f32>(1.0))) * w;
        wsum += w;
    }
    return acc / wsum;
}
