struct Params { density: f32, stagger: f32, softness: f32 }

// Adapted from Drift by CutWire Studios (GPL-3.0-or-later), transitions/honeycomb_hexagon.

fn d_aspect() -> f32 {
    return frame.size.x / max(frame.size.y, 1.0);
}

fn d_mod(x: vec2<f32>, y: vec2<f32>) -> vec2<f32> {
    return x - y * floor(x / y);
}

// The nearest centre on a pointy top hex lattice: xy the offset from it, zw the centre.
fn d_hex(p: vec2<f32>) -> vec4<f32> {
    let r = vec2<f32>(1.0, 1.7320508);
    let h = r * 0.5;
    let a = d_mod(p, r) - h;
    let b = d_mod(p - h, r) - h;
    var gv = b;
    if (dot(a, a) < dot(b, b)) {
        gv = a;
    }
    return vec4<f32>(gv, p - gv);
}

fn d_hex_dist(q: vec2<f32>) -> f32 {
    let p = abs(q);
    return max(p.x, dot(p, normalize(vec2<f32>(1.0, 1.7320508))));
}

fn transition(uv: vec2<f32>, progress: f32) -> vec4<f32> {
    let hc = d_hex(vec2<f32>(uv.x * d_aspect(), uv.y) * params.density);
    let stagger = params.stagger * 0.01;
    let soft = params.softness * 0.01;
    let t = clamp(progress * (1.0 + stagger) - hash(floor(hc.zw * 2.0), 4.0) * stagger, 0.0, 1.0);
    // Each cell grows its own hexagon of the next shot, from nothing to the whole cell.
    let r = mix(-soft, 0.5 + soft, t);
    let m = smoothstep(r + soft, r - soft, d_hex_dist(hc.xy));
    return mix(from_at(uv), to_at(uv), m);
}
