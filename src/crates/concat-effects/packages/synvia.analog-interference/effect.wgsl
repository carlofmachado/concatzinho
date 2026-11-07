struct Params { stretch: f32, width: f32, noise: f32, flash: f32 }

// Adapted from Drift by CutWire Studios (GPL-3.0-or-later), transitions/analog_interference.

fn d_aspect() -> f32 {
    return frame.size.x / max(frame.size.y, 1.0);
}

// 0 at both ends of the cut, 1 in between: glows and grain never sit on
// the first or the last frame.
fn d_alive(progress: f32) -> f32 {
    return smoothstep(0.0, 0.06, progress) * (1.0 - smoothstep(0.94, 1.0, progress));
}

// Mirrors a reading that falls off the frame back onto it, so a zoom or a
// warp never pulls in the empty space around the picture.
fn d_mirror(uv: vec2<f32>) -> vec2<f32> {
    let t = fract(uv * 0.5) * 2.0;
    return vec2<f32>(1.0) - abs(t - vec2<f32>(1.0));
}

fn transition(uv: vec2<f32>, progress: f32) -> vec4<f32> {
    let aspect = d_aspect();
    let width = params.width * 0.01;
    let d = (uv - vec2<f32>(0.5)) * vec2<f32>(aspect, 1.0);
    let r = length(d);
    let dir = normalize(d + vec2<f32>(1e-6));
    // One front, past the far corner by the end of the cut.
    let front = progress * (0.5 * sqrt(aspect * aspect + 1.0) + width * 2.0);
    let ring = smoothstep(width, 0.0, abs(r - front)) * d_alive(progress);
    let off = dir * ring * params.stretch * 0.01 * 0.18 / vec2<f32>(aspect, 1.0);
    let a = from_at(d_mirror(uv - off));
    let b = to_at(d_mirror(uv + off * 0.5));
    let m = smoothstep(0.0, width, front - r);
    let c = mix(a, b, clamp(m, 0.0, 1.0));
    let n = hash(floor(uv * frame.size), floor(progress * 60.0));
    var lit = mix(to_display(c.rgb), vec3<f32>(n), ring * params.noise * 0.01 * c.a);
    lit += vec3<f32>(ring * params.flash * 0.01 * c.a);
    return vec4<f32>(from_display(lit), c.a);
}
