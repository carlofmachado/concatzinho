struct Params { segments: f32, spin: f32, zoom: f32 }

// Adapted from Drift by CutWire Studios (GPL-3.0-or-later), transitions/kaleidoscope_spin.

fn d_aspect() -> f32 {
    return frame.size.x / max(frame.size.y, 1.0);
}

// Mirrors a reading that falls off the frame back onto it, so a zoom or a
// warp never pulls in the empty space around the picture.
fn d_mirror(uv: vec2<f32>) -> vec2<f32> {
    let t = fract(uv * 0.5) * 2.0;
    return vec2<f32>(1.0) - abs(t - vec2<f32>(1.0));
}

fn transition(uv: vec2<f32>, progress: f32) -> vec4<f32> {
    let aspect = d_aspect();
    let d = (uv - vec2<f32>(0.5)) * vec2<f32>(aspect, 1.0);
    let r = length(d);
    let ang = atan2(d.y, d.x);
    // Folds in and back out, so both ends are unmirrored.
    let amt = sin(progress * 3.14159265);
    let seg = 6.28318530718 / max(floor(params.segments), 2.0);
    let x = ang + progress * params.spin * 0.01 * 6.28318530718 + 100.0 * seg;
    var folded = x - seg * floor(x / seg);
    folded = abs(folded - seg * 0.5);
    let a2 = mix(ang, folded, amt);
    let rr = r * (1.0 - params.zoom * 0.01 * amt);
    let suv = vec2<f32>(0.5) + vec2<f32>(cos(a2), sin(a2)) * rr / vec2<f32>(aspect, 1.0);
    let m = d_mirror(suv);
    return mix(from_at(m), to_at(m), smoothstep(0.4, 0.6, progress));
}
