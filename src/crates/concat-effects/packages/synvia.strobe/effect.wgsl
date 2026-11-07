struct Params { flash: f32, tint: f32 }

// Adapted from Drift by CutWire Studios (GPL-3.0-or-later), effects/strobe_flash.

fn effect(uv: vec2<f32>) -> vec4<f32> {
    let src = sample(uv);
    let f = params.flash * 0.01;
    let lift = mix(vec3<f32>(1.0), vec3<f32>(1.0, 0.95, 0.85), params.tint * 0.01);
    var d = mix(to_display(src.rgb), lift, f);
    d = d + vec3<f32>(f * 0.35) * (vec3<f32>(1.0) - clamp(d, vec3<f32>(0.0), vec3<f32>(1.0)));
    return vec4<f32>(from_display(d), src.a);
}
