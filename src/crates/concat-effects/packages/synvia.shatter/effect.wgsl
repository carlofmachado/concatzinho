struct Params { cells: f32, push: f32, stagger: f32, spin: f32 }

// Adapted from Drift by CutWire Studios (GPL-3.0-or-later), transitions/voronoi_shatter.

fn d_aspect() -> f32 {
    return frame.size.x / max(frame.size.y, 1.0);
}

// Straight alpha source over.
fn d_over(top: vec4<f32>, bot: vec4<f32>) -> vec4<f32> {
    let oa = top.a + bot.a * (1.0 - top.a);
    if (oa <= 0.0001) {
        return vec4<f32>(0.0);
    }
    return vec4<f32>((top.rgb * top.a + bot.rgb * bot.a * (1.0 - top.a)) / oa, oa);
}

fn d_hash2(p: vec2<f32>, seed: f32) -> vec2<f32> {
    return vec2<f32>(hash(p, seed), hash(p, seed + 0.5));
}

fn transition(uv: vec2<f32>, progress: f32) -> vec4<f32> {
    let aspect = d_aspect();
    let g = vec2<f32>(uv.x * aspect, uv.y) * params.cells;
    let base = floor(g);
    // Nearest point of a jittered lattice: that shard owns this pixel.
    var best_d = 1e9;
    var best_id = base;
    for (var j = -1; j <= 1; j++) {
        for (var i = -1; i <= 1; i++) {
            let nb = base + vec2<f32>(f32(i), f32(j));
            let d = distance(nb + d_hash2(nb, 6.0), g);
            if (d < best_d) {
                best_d = d;
                best_id = nb;
            }
        }
    }
    let stagger = params.stagger * 0.01;
    let t = clamp(progress * (1.0 + stagger) - hash(best_id, 7.0) * stagger, 0.0, 1.0);
    let dir = normalize(d_hash2(best_id, 8.0) * 2.0 - vec2<f32>(1.0) + vec2<f32>(1e-5));
    let ang = (hash(best_id, 9.0) - 0.5) * params.spin * 0.01 * t;
    let cs = cos(ang);
    let sn = sin(ang);
    let rot = vec2<f32>(cs * dir.x + sn * dir.y, -sn * dir.x + cs * dir.y);
    // Shards speed up as they leave, then fade.
    let off = rot * t * t * params.push * 0.01 / vec2<f32>(aspect, 1.0);
    var a = from_at(uv + off);
    a.a *= 1.0 - smoothstep(0.35, 1.0, t);
    return d_over(a, to_at(uv));
}
