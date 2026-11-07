struct Params { amount: f32, shadow: vec4<f32>, highlight: vec4<f32>, contrast: f32 }

// Adapted from Drift by CutWire Studios (GPL-3.0-or-later), effects/duotone.

fn effect(uv: vec2<f32>) -> vec4<f32> {
    let src = sample(uv);
    let d = to_display(src.rgb);
    let l = clamp(luma(d), 0.0, 1.0);
    let c = clamp(mix(l, smoothstep(0.0, 1.0, l), params.contrast * 0.02), 0.0, 1.0);
    let duo = mix(params.shadow.rgb, params.highlight.rgb, c);
    return vec4<f32>(from_display(mix(d, duo, params.amount * 0.01)), src.a);
}
