struct Params { amount: f32, grain: f32, scratches: f32, weave: f32, flicker: f32 }

// Adapted from Drift by CutWire Studios (GPL-3.0-or-later), effects/super8_film.

// One pixel of a 1080 line picture, in this layer's pixels: sizes given in
// pixels look the same at every resolution.
fn d_px() -> f32 {
    return max(frame.size.y / 1080.0, 0.25);
}

fn effect(uv: vec2<f32>) -> vec4<f32> {
    let src = sample(uv);
    let amt = params.amount * 0.01;
    let fi = floor(frame.time * 18.0);
    let flick = 1.0 - params.flicker * 0.01 * hash(vec2<f32>(fi, 17.0), 1.0) * 0.5;
    let wob = params.weave * 0.0001;
    let wuv = uv + vec2<f32>(sin(fi * 0.31), cos(fi * 0.27)) * wob;
    var c = to_display(sample(clamp(wuv, vec2<f32>(0.0), vec2<f32>(1.0))).rgb) * flick;
    let pix = floor(uv * frame.size / d_px());
    c += vec3<f32>((hash(pix, fi) * 2.0 - 1.0) * params.grain * 0.01 * 0.08);
    let s = params.scratches * 0.01;
    let line = hash(vec2<f32>(floor(pix.x / 3.0), 41.0), fi);
    if (s > 0.01 && line > 1.0 - s * 0.02) {
        c *= 0.85;
    }
    if (hash(pix, fi + 0.5) > 0.998 - s * 0.003) {
        c = mix(c, vec3<f32>(0.9), 0.6);
    }
    return vec4<f32>(from_display(mix(to_display(src.rgb), c, amt)), src.a);
}
