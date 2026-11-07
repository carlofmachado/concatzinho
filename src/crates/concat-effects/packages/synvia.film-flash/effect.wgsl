struct Params { amount: f32, warmth: f32, flicker: f32, side: f32, seed: f32 }

// Adapted from Drift by CutWire Studios (GPL-3.0-or-later), effects/film_burn.

fn effect(uv: vec2<f32>) -> vec4<f32> {
    let src = sample(uv);
    let fi = floor(frame.time * 24.0);
    var mode = params.side;
    if (mode > 3.5) {
        // A new side every half second, not every frame.
        mode = floor(hash(vec2<f32>(floor(frame.time * 2.0), 4.0), params.seed) * 4.0);
    }
    let flick = 1.0 - params.flicker * 0.01 + params.flicker * 0.01 * hash(vec2<f32>(fi, 5.0), params.seed);
    let w = params.warmth * 0.01;
    let colour = vec3<f32>(1.0, (100.0 + w * 155.0) / 255.0, (15.0 + w * 120.0) / 255.0);
    var gradient = pow(1.0 - uv.x, 1.7);
    var blob_c = vec2<f32>(0.05, 0.5);
    if (mode > 0.5 && mode < 1.5) {
        gradient = pow(uv.x, 1.7);
        blob_c = vec2<f32>(0.95, 0.5);
    } else if (mode > 1.5 && mode < 2.5) {
        gradient = pow(1.0 - uv.y, 1.7);
        blob_c = vec2<f32>(0.5, 0.05);
    } else if (mode > 2.5) {
        gradient = pow(uv.y, 1.7);
        blob_c = vec2<f32>(0.5, 0.95);
    }
    let blob = max(0.0, 1.0 - distance(uv, blob_c) / 0.75);
    // Soft blotches of density, not pixel grain: the leak lies on the film.
    let q = uv * vec2<f32>(frame.size.x / max(frame.size.y, 1.0), 1.0) * 9.0 + vec2<f32>(fi * 0.37, 0.0);
    let i = floor(q);
    var f = fract(q);
    f = f * f * (vec2<f32>(3.0) - 2.0 * f);
    let v = mix(mix(hash(i, params.seed), hash(i + vec2<f32>(1.0, 0.0), params.seed), f.x),
        mix(hash(i + vec2<f32>(0.0, 1.0), params.seed), hash(i + vec2<f32>(1.0, 1.0), params.seed), f.x), f.y);
    let n = 0.7 + 0.3 * v;
    let leak = clamp(max(gradient, blob * 0.85) * n * flick * params.amount * 0.01, 0.0, 1.0);
    return vec4<f32>(from_display(to_display(src.rgb) + colour * leak), src.a);
}
