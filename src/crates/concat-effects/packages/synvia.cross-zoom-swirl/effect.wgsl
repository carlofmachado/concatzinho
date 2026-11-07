struct Params { zoom: f32, swirl: f32, blur: f32 }

// Adapted from Drift by CutWire Studios (GPL-3.0-or-later), transitions/cross_zoom_swirl.

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
    let amt = sin(progress * 3.14159265);
    // The twist falls off with the radius: the centre spins hardest.
    let ang = atan2(d.y, d.x) + amt * params.swirl * 0.01 * (1.0 - smoothstep(0.0, 0.75, r));
    let dir = vec2<f32>(cos(ang), sin(ang));
    let zoom = params.zoom * 0.01;
    let za = 1.0 + amt * zoom;
    let zb = 1.0 - amt * zoom * 0.8;
    let mix_t = smoothstep(0.35, 0.65, progress);
    var acc = vec4<f32>(0.0);
    for (var i = 0; i < 12; i++) {
        let s = f32(i) / 11.0 - 0.5;
        let scale = 1.0 + s * amt * params.blur * 0.01 * 0.25;
        let ua = vec2<f32>(0.5) + dir * r * za * scale / vec2<f32>(aspect, 1.0);
        let ub = vec2<f32>(0.5) + dir * r * zb * scale / vec2<f32>(aspect, 1.0);
        acc += mix(from_at(d_mirror(ua)), to_at(d_mirror(ub)), mix_t);
    }
    return acc / 12.0;
}
