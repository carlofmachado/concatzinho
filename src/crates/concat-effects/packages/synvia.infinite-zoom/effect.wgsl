struct Params { amount: f32, cx: f32, cy: f32, turns: f32, zoom: f32 }

// Adapted from Drift by CutWire Studios (GPL-3.0-or-later), effects/droste_zoom.

fn d_aspect() -> f32 {
    return frame.size.x / max(frame.size.y, 1.0);
}

// Mirrors a reading that falls off the layer back onto it.
fn d_mirror(uv: vec2<f32>) -> vec2<f32> {
    let t = fract(uv * 0.5) * 2.0;
    return vec2<f32>(1.0) - abs(t - vec2<f32>(1.0));
}

fn effect(uv: vec2<f32>) -> vec4<f32> {
    let src = sample(uv);
    let aspect = d_aspect();
    let c = vec2<f32>(params.cx, params.cy) * 0.01;
    let p = (uv - c) * vec2<f32>(aspect, 1.0);
    let r = length(p) + 1e-5;
    let a = atan2(p.y, p.x);
    let log_r = log(r);
    let new_a = a + params.turns * 6.2831853 * log_r;
    let new_r = exp(log_r / max(params.zoom * 0.01, 0.5));
    let at = d_mirror(c + vec2<f32>(cos(new_a), sin(new_a)) * new_r / vec2<f32>(aspect, 1.0));
    return mix(src, sample(at), params.amount * 0.01);
}
