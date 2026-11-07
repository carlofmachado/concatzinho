struct Params { glow: f32, width: f32, distort: f32, softness: f32, flare: vec4<f32> }

// Adapted from Drift by CutWire Studios (GPL-3.0-or-later), transitions/lens_flare_wipe.

// 0 at both ends of the cut, 1 in between: glows and grain never sit on
// the first or the last frame.
fn d_alive(progress: f32) -> f32 {
    return smoothstep(0.0, 0.06, progress) * (1.0 - smoothstep(0.94, 1.0, progress));
}

fn transition(uv: vec2<f32>, progress: f32) -> vec4<f32> {
    let width = params.width * 0.01;
    let soft = params.softness * 0.01;
    // The streak starts and ends off frame.
    let sweep = mix(-0.3, 1.3, progress);
    let d = uv.x - sweep;
    let core = exp(-d * d / max(width * width * 0.02, 1e-5));
    let halo = exp(-d * d / max(width * width * 0.4, 1e-5)) * exp(-pow(abs(uv.y - 0.5) * 2.0, 2.0) / 0.7);
    let glow = (core + halo * 0.55) * d_alive(progress);
    let push = vec2<f32>(core * 0.03 * params.distort * 0.01, 0.0);
    let a = from_at(uv + push);
    let b = to_at(uv - push);
    let m = smoothstep(-soft, soft, -d);
    let c = mix(a, b, clamp(m, 0.0, 1.0));
    let lit = to_display(c.rgb) + params.flare.rgb * glow * params.glow * 0.01 * c.a;
    return vec4<f32>(from_display(lit), c.a);
}
