struct Params { punch: f32, blur: f32, cx: f32, cy: f32 }

// Adapted from Drift by CutWire Studios (GPL-3.0-or-later), effects/zoom_pulse.

fn effect(uv: vec2<f32>) -> vec4<f32> {
    let p = params.punch * 0.01;
    if (p <= 1e-5) {
        return sample(uv);
    }
    let c = vec2<f32>(params.cx, params.cy) * 0.01;
    let d = uv - c;
    let zoom = 1.0 - p * 0.18;
    let smear = mix(0.0, 0.06, params.blur * 0.01) * p;
    var acc = vec4<f32>(0.0);
    var wsum = 0.0;
    for (var i = 0; i < 12; i++) {
        let t = f32(i) / 11.0 - 0.5;
        let w = 1.0 - abs(t) * 2.0 + 0.05;
        acc += sample(clamp(c + d * (zoom + smear * t), vec2<f32>(0.0), vec2<f32>(1.0))) * w;
        wsum += w;
    }
    return acc / wsum;
}
