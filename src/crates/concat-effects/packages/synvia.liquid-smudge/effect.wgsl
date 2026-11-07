struct Params { strength: f32, swirl: f32, melt: f32, bleed: f32, scale: f32 }

// Adapted from Drift by CutWire Studios (GPL-3.0-or-later), transitions/liquid_smudge.

fn d_noise(p: vec2<f32>) -> f32 {
    let i = floor(p);
    var f = fract(p);
    f = f * f * (vec2<f32>(3.0) - 2.0 * f);
    let a = hash(i, 0.0);
    let b = hash(i + vec2<f32>(1.0, 0.0), 0.0);
    let c = hash(i + vec2<f32>(0.0, 1.0), 0.0);
    let d = hash(i + vec2<f32>(1.0, 1.0), 0.0);
    return mix(mix(a, b, f.x), mix(c, d, f.x), f.y);
}

fn d_fbm(start: vec2<f32>) -> f32 {
    var p = start;
    var v = 0.0;
    var amp = 0.5;
    for (var i = 0; i < 5; i++) {
        v += amp * d_noise(p);
        p = p * 2.02;
        amp *= 0.5;
    }
    return v;
}

// Mirrors a reading that falls off the frame back onto it, so a zoom or a
// warp never pulls in the empty space around the picture.
fn d_mirror(uv: vec2<f32>) -> vec2<f32> {
    let t = fract(uv * 0.5) * 2.0;
    return vec2<f32>(1.0) - abs(t - vec2<f32>(1.0));
}

fn transition(uv: vec2<f32>, progress: f32) -> vec4<f32> {
    // Drift advects a warp field over three passes; here the three steps run
    // in one, each walking the warp the step before left.
    var w = vec2<f32>(0.0);
    for (var k = 0; k < 3; k++) {
        let p = uv + w * 0.1;
        let n1 = d_fbm(p * params.scale + vec2<f32>(0.0, -progress * 1.2));
        let n2 = d_fbm(p * params.scale + vec2<f32>(3.7, 8.1) + vec2<f32>(0.0, progress * 1.2));
        let grad = vec2<f32>(n1, n2) - vec2<f32>(0.5);
        let add = vec2<f32>(grad.y, -grad.x) * params.swirl * 0.01 + vec2<f32>(0.0, 1.0) * params.melt * 0.005;
        w = clamp(w + add * progress * 0.12, vec2<f32>(-1.0), vec2<f32>(1.0));
    }
    let amt = sin(progress * 3.14159265) * params.strength * 0.01;
    let a = from_at(d_mirror(uv + w * amt));
    let b = to_at(d_mirror(uv - w * amt * 0.6));
    // The most warped parts hand over first.
    var m = smoothstep(0.2, 0.85, progress + (length(w) - 0.3) * params.bleed * 0.01);
    m = max(m, smoothstep(0.9, 1.0, progress));
    return mix(a, b, clamp(m, 0.0, 1.0));
}
