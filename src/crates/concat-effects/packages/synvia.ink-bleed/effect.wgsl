struct Params { scale: f32, distort: f32, darkness: f32, softness: f32, ink: vec4<f32> }

// Adapted from Drift by CutWire Studios (GPL-3.0-or-later), transitions/ink_bleed.

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

fn transition(uv: vec2<f32>, progress: f32) -> vec4<f32> {
    let aspect = d_aspect();
    let p = vec2<f32>(uv.x * aspect, uv.y);
    let distort = params.distort * 0.01;
    let soft = params.softness * 0.01;
    let c1 = vec2<f32>(0.30 * aspect, 0.35);
    let c2 = vec2<f32>(0.78 * aspect, 0.62);
    let c3 = vec2<f32>(0.52 * aspect, 0.18);
    let d = min(min(distance(p, c1), distance(p, c2)), distance(p, c3));
    let n = d_fbm(uv * params.scale) - 0.5;
    // The front must cross the farthest point of the frame whatever its shape.
    let reach = length(vec2<f32>(aspect, 1.0)) * 0.75 + 0.2;
    // Lifted by half the distortion so no blot of ink shows on the first frame.
    let th = d * 1.5 + n * distort + distort * 0.5 + soft - progress * (reach + distort + 2.0 * soft);
    let m = 1.0 - smoothstep(-soft, soft, th);
    let c = mix(from_at(uv), to_at(uv), m);
    // A dark rim where the paper is still soaking, laid on in the display encoding.
    let rim = smoothstep(soft * 3.0, 0.0, abs(th));
    let alive = 1.0 - smoothstep(0.9, 1.0, progress);
    let k = clamp(rim * params.darkness * 0.01 * alive, 0.0, 1.0) * c.a;
    return vec4<f32>(from_display(mix(to_display(c.rgb), params.ink.rgb, k)), c.a);
}
