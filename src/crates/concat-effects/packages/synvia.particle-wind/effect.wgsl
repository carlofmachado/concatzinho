struct Params { strength: f32, turbulence: f32, grain: f32, spread: f32, direction: f32 }

// Adapted from Drift by CutWire Studios (GPL-3.0-or-later), transitions/particle_wind.

fn d_aspect() -> f32 {
    return frame.size.x / max(frame.size.y, 1.0);
}

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

// Straight alpha source over.
fn d_over(top: vec4<f32>, bot: vec4<f32>) -> vec4<f32> {
    let oa = top.a + bot.a * (1.0 - top.a);
    if (oa <= 0.0001) {
        return vec4<f32>(0.0);
    }
    return vec4<f32>((top.rgb * top.a + bot.rgb * bot.a * (1.0 - top.a)) / oa, oa);
}

fn transition(uv: vec2<f32>, progress: f32) -> vec4<f32> {
    let n1 = d_fbm(uv * 6.0 + vec2<f32>(progress * 1.5, 0.0));
    let n2 = d_fbm(uv * 6.0 + vec2<f32>(5.2, 1.3) + vec2<f32>(0.0, progress * 1.5));
    let flow = (vec2<f32>(n1, n2) - vec2<f32>(0.5)) * 2.0;
    let g = d_fbm(uv * params.grain);
    let rad = radians(params.direction);
    let wind = vec2<f32>(cos(rad), sin(rad));
    let spread = params.spread * 0.01;
    // Grains start still, then tear away.
    let t = progress * progress;
    let off = (wind + flow * params.turbulence * 0.01) * t * params.strength * 0.01 * 0.6 / vec2<f32>(d_aspect(), 1.0);
    var a = from_at(uv - off);
    let b = to_at(uv);
    let lead = dot(uv - vec2<f32>(0.5), wind) * 0.5 + 0.5;
    let th = progress * (1.0 + spread) - (g * 0.7 + lead * 0.3) * spread;
    a.a *= 1.0 - smoothstep(0.0, 0.3, th);
    a = vec4<f32>(a.rgb + vec3<f32>(smoothstep(0.8, 1.0, g)) * a.a * 0.12, a.a);
    return d_over(a, b);
}
