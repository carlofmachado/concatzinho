struct Params { amount: f32, frequency: f32, speed: f32, axis: f32 }

// Adapted from Drift by CutWire Studios (GPL-3.0-or-later), effects/wave_warp.

// Mirrors a reading that falls off the layer back onto it.
fn d_mirror(uv: vec2<f32>) -> vec2<f32> {
    let t = fract(uv * 0.5) * 2.0;
    return vec2<f32>(1.0) - abs(t - vec2<f32>(1.0));
}

fn effect(uv: vec2<f32>) -> vec4<f32> {
    let a = params.amount * 0.01 * 0.04;
    let t = frame.time * params.speed * 0.01;
    var at = uv;
    if (params.axis < 0.5) {
        at.x += sin(uv.y * params.frequency * 6.2831853 + t) * a;
    } else {
        at.y += sin(uv.x * params.frequency * 6.2831853 + t) * a;
    }
    return sample(d_mirror(at));
}
