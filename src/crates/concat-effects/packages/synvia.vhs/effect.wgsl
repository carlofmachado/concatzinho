struct Params { roll: f32, bar: f32, noise: f32, chroma: f32, scanlines: f32, jitter: f32 }

// Adapted from Drift by CutWire Studios (GPL-3.0-or-later), transitions/vhs_scanline.

fn transition(uv: vec2<f32>, progress: f32) -> vec4<f32> {
    let peak = sin(progress * 3.14159265);
    let tick = floor(progress * 48.0);
    // The sync bar rolls down the frame.
    let bar = fract(uv.y + progress * params.roll * 0.01);
    let in_bar = step(bar, params.bar * 0.01);
    var j = (hash(vec2<f32>(floor(uv.y * 220.0), tick), 1.0) - 0.5) * params.jitter * 0.01 * peak;
    j += in_bar * (hash(vec2<f32>(tick, 0.0), 2.0) - 0.5) * 0.08 * peak;
    let uj = vec2<f32>(uv.x + j, uv.y);
    let s = vec2<f32>(params.chroma * peak / max(frame.size.x, 1.0), 0.0);
    let a = vec4<f32>(from_at(uj + s).r, from_at(uj).g, from_at(uj - s).b, from_at(uj).a);
    let b = vec4<f32>(to_at(uj + s).r, to_at(uj).g, to_at(uj - s).b, to_at(uj).a);
    let c = mix(a, b, smoothstep(0.4, 0.6, progress));
    let n = hash(floor(uv * frame.size), tick);
    var lit = mix(to_display(c.rgb), vec3<f32>(n), params.noise * 0.01 * peak * (0.25 + in_bar * 0.75) * c.a);
    lit *= 1.0 - params.scanlines * 0.01 * peak * c.a * (0.5 + 0.5 * sin(uv.y * frame.size.y * 3.14159265));
    return vec4<f32>(from_display(lit), c.a);
}
