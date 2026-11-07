struct Params { cx: f32, cy: f32, radius: f32, width: f32, strength: f32, speed: f32 }

// Adapted from Drift by CutWire Studios (GPL-3.0-or-later), effects/shockwave_pulse.

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
    if (dist < 1e-4 || params.strength <= 0.0) {
        return sample(uv);
    }
    let far = max(length(max(c, vec2<f32>(1.0) - c) * vec2<f32>(aspect, 1.0)), 0.1);
    var wr = params.radius * 0.01;
    if (params.speed > 0.0) {
        wr = fract(frame.time * params.speed * 0.5 + wr);
    }
    let half_w = max(params.width * 0.005, 1e-5);
    let delta = abs(dist / far - wr);
    var env = 0.0;
    if (delta < half_w) {
        let k = 1.0 - delta / half_w;
        env = k * k * (3.0 - 2.0 * k);
    }
    let disp = params.strength * 0.01 * 0.25 * min(aspect, 1.0);
    let at = c + (d - d / dist * env * disp) / vec2<f32>(aspect, 1.0);
    return sample(d_mirror(at));
}
