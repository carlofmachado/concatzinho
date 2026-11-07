struct Params { blockiness: f32, swap: f32 }

// Adapted from Drift by CutWire Studios (GPL-3.0-or-later), transitions/pixelate_matrix.

fn d_aspect() -> f32 {
    return frame.size.x / max(frame.size.y, 1.0);
}

fn transition(uv: vec2<f32>, progress: f32) -> vec4<f32> {
    // Blocks peak at the middle and are gone at both ends.
    let amt = sin(progress * 3.14159265) * params.blockiness * 0.01;
    let cols = mix(frame.size.x, 6.0, amt);
    let grid = vec2<f32>(cols, max(cols / d_aspect(), 1.0));
    let quv = (floor(uv * grid) + vec2<f32>(0.5)) / grid;
    let suv = mix(uv, quv, amt);
    let c = mix(from_at(suv), to_at(suv), smoothstep(0.35, 0.65, progress));
    let h = hash(floor(uv * grid), 0.0);
    let swap = amt * params.swap * 0.01 * step(0.35, h);
    return vec4<f32>(mix(c.rgb, c.gbr, swap), c.a);
}
