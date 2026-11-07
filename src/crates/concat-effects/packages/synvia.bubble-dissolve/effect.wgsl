struct Params { cells: f32, size: f32, rise: f32, stagger: f32, refraction: f32 }

// Adapted from Drift by CutWire Studios (GPL-3.0-or-later), transitions/bubbling_dissolve.

fn d_aspect() -> f32 {
    return frame.size.x / max(frame.size.y, 1.0);
}

fn transition(uv: vec2<f32>, progress: f32) -> vec4<f32> {
    let aspect = d_aspect();
    let stagger = params.stagger * 0.01;
    let g = vec2<f32>(uv.x * aspect, uv.y) * params.cells;
    let base = floor(g);
    // A bubble grows past its own cell, so the cells around count too:
    // the one that covers this pixel most wins.
    var m = 0.0;
    var away = vec2<f32>(0.0, 1.0);
    for (var j = -1; j <= 1; j++) {
        for (var i = -1; i <= 1; i++) {
            let id = base + vec2<f32>(f32(i), f32(j));
            let f = g - id - vec2<f32>(0.5);
            let r1 = hash(id, 1.0);
            let r2 = hash(id, 2.0);
            let t = clamp(progress * (1.0 + stagger) - r1 * stagger, 0.0, 1.0);
            // y grows downwards, so rising is a negative drift.
            let c = vec2<f32>((r2 - 0.5) * 0.4, (r1 - 0.5) * 0.3 - params.rise * 0.01 * t);
            let rad = t * (0.55 + r2 * 0.35) * params.size * 0.01;
            let d = length(f - c);
            let cover = 1.0 - smoothstep(rad - 0.07, rad + 0.07, d);
            if (cover > m) {
                m = cover;
                away = f - c;
            }
        }
    }
    m = max(m, smoothstep(0.88, 1.0, progress));
    // Each bubble is a weak lens on the incoming shot.
    let refr = normalize(away + vec2<f32>(1e-5)) * m * (1.0 - m) * params.refraction * 0.01 * 0.06;
    let b = to_at(uv + refr / vec2<f32>(aspect, 1.0));
    return mix(from_at(uv), b, m);
}
