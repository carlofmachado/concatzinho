struct Params { scale: f32, glow: f32, edge: f32, hot: vec4<f32>, cool: vec4<f32> }

// Adapted from Drift by CutWire Studios (GPL-3.0-or-later), transitions/plasma_burn.

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

fn transition(uv: vec2<f32>, progress: f32) -> vec4<f32> {
    let n = d_fbm(uv * params.scale + vec2<f32>(progress * 0.4, progress * 0.25));
    let edge = params.edge * 0.01;
    // The front sweeps past the whole noise range: all outgoing at 0, all incoming at 1.
    let front = mix(-0.15, 1.15, progress);
    let d = n - front;
    let m = 1.0 - smoothstep(0.0, 0.04, d);
    let c = mix(from_at(uv), to_at(uv), m);
    let band = smoothstep(edge, 0.0, abs(d));
    let alive = 1.0 - smoothstep(0.88, 1.0, progress);
    let fire = mix(params.cool.rgb, params.hot.rgb, smoothstep(edge, 0.0, abs(d + 0.02)));
    let lit = to_display(c.rgb) + fire * band * params.glow * 0.01 * alive * c.a;
    return vec4<f32>(from_display(lit), c.a);
}
