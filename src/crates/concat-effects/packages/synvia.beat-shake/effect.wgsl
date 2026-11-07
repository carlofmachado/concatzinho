struct Params { amount: f32, rotation: f32, seed: f32 }

// Adapted from Drift by CutWire Studios (GPL-3.0-or-later), effects/beat_shake.

fn d_aspect() -> f32 {
    return frame.size.x / max(frame.size.y, 1.0);
}

fn effect(uv: vec2<f32>) -> vec4<f32> {
    let a = params.amount * 0.01;
    if (a <= 1e-5) {
        return sample(uv);
    }
    let aspect = d_aspect();
    // Scaled up a little so the shake never shows the edge.
    let overscan = 1.0 + a * 0.12;
    let p = (uv - vec2<f32>(0.5)) / overscan;
    let t = frame.time * 48.0 + params.seed * 0.97;
    var jitter = vec2<f32>(sin(t * 1.7), cos(t * 2.3)) * a * 0.035;
    jitter += vec2<f32>(hash(vec2<f32>(floor(t), 0.0), 1.0), hash(vec2<f32>(floor(t), 1.0), 1.0)) * a * 0.02 - vec2<f32>(a * 0.01);
    let rot = a * params.rotation * 0.01 * 0.08 * sin(t * 3.1);
    let q = p * vec2<f32>(aspect, 1.0);
    let r = vec2<f32>(q.x * cos(rot) - q.y * sin(rot), q.x * sin(rot) + q.y * cos(rot)) / vec2<f32>(aspect, 1.0);
    return sample(clamp(r + vec2<f32>(0.5) + jitter, vec2<f32>(0.0), vec2<f32>(1.0)));
}
