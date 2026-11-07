struct Params { density: f32, stagger: f32, shading: f32 }

// Adapted from Drift by CutWire Studios (GPL-3.0-or-later), transitions/triangle_mosaic.

fn d_aspect() -> f32 {
    return frame.size.x / max(frame.size.y, 1.0);
}

fn transition(uv: vec2<f32>, progress: f32) -> vec4<f32> {
    let grid = vec2<f32>(params.density, max(floor(params.density / d_aspect()), 1.0));
    let stagger = params.stagger * 0.01;
    let g = uv * grid;
    let id = floor(g);
    let f = fract(g);
    let upper = step(f.x + f.y, 1.0);
    let rnd = hash(id, 5.0 + upper * 17.0);
    let t = clamp(progress * (1.0 + stagger) - rnd * stagger, 0.0, 1.0);
    // A flip squashes the tile through zero and swaps the picture at the turn.
    let squash = cos(t * 3.14159265);
    let reveal = step(squash, 0.0);
    let center = (id + vec2<f32>(0.5)) / grid;
    let suv = center + (uv - center) / vec2<f32>(max(abs(squash), 0.06), 1.0);
    let c = mix(from_at(suv), to_at(suv), reveal);
    let shade = 1.0 - params.shading * 0.01 * (1.0 - abs(squash));
    return vec4<f32>(from_display(to_display(c.rgb) * shade), c.a);
}
