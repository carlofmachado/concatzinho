struct Params { amplitude: f32, frequency: f32, speed: f32, cx: f32, cy: f32 }

// Adapted from Drift by CutWire Studios (GPL-3.0-or-later), effects/ripple_water.

// One pixel of a 1080 line picture, in this layer's pixels: sizes given in
// pixels look the same at every resolution.
fn d_px() -> f32 {
    return max(frame.size.y / 1080.0, 0.25);
}

fn d_aspect() -> f32 {
    return frame.size.x / max(frame.size.y, 1.0);
}

// Mirrors a reading that falls off the layer back onto it.
fn d_mirror(uv: vec2<f32>) -> vec2<f32> {
    let t = fract(uv * 0.5) * 2.0;
    return vec2<f32>(1.0) - abs(t - vec2<f32>(1.0));
}

fn effect(uv: vec2<f32>) -> vec4<f32> {
    let aspect = d_aspect();
    let c = vec2<f32>(params.cx, params.cy) * 0.01;
    let d = (uv - c) * vec2<f32>(aspect, 1.0);
    let dist = length(d);
    if (dist < 1e-4) {
        return sample(uv);
    }
    let far = max(length(c * vec2<f32>(aspect, 1.0)), 0.1);
    let wave = sin(dist / far * params.frequency * 6.2831853 + frame.time * params.speed * 6.2831853);
    // Amplitude in pixels of a 1080 line picture, along the ring's radius.
    let push = wave * params.amplitude * d_px() / frame.size.y;
    let at = c + (d + d / dist * push) / vec2<f32>(aspect, 1.0);
    return sample(d_mirror(at));
}
