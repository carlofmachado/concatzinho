struct Params { segments: f32, rotation: f32, cx: f32, cy: f32, zoom: f32 }

// Adapted from Drift by CutWire Studios (GPL-3.0-or-later), effects/kaleidoscope.

fn d_aspect() -> f32 {
    return frame.size.x / max(frame.size.y, 1.0);
}

// Mirrors a reading that falls off the layer back onto it.
fn d_mirror(uv: vec2<f32>) -> vec2<f32> {
    let t = fract(uv * 0.5) * 2.0;
    return vec2<f32>(1.0) - abs(t - vec2<f32>(1.0));
}

fn effect(uv: vec2<f32>) -> vec4<f32> {
    let aspect = d_aspect();
    let c = vec2<f32>(params.cx, params.cy) * 0.01;
    let p = (uv - c) * vec2<f32>(aspect, 1.0);
    let r = length(p);
    let turned = atan2(p.y, p.x) + radians(params.rotation);
    let slice = 6.2831853 / clamp(floor(params.segments + 0.5), 2.0, 12.0);
    let k = turned / slice + 1000.0;
    var a = (k - floor(k)) * slice;
    if (floor(k) - 2.0 * floor(floor(k) / 2.0) > 0.5) {
        a = slice - a;
    }
    let at = c + vec2<f32>(cos(a), sin(a)) * r / max(params.zoom * 0.01, 0.5) / vec2<f32>(aspect, 1.0);
    return sample(d_mirror(at));
}
