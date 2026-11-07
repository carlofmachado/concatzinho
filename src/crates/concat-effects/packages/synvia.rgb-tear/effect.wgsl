struct Params { tear: f32, split: f32, lines: f32, steps: f32 }

// Adapted from Drift by CutWire Studios (GPL-3.0-or-later), transitions/rgb_displacement.

fn transition(uv: vec2<f32>, progress: f32) -> vec4<f32> {
    let peak = sin(progress * 3.14159265);
    // Progress in steps, so a tear holds for a few frames instead of crawling.
    let tick = floor(progress * params.steps);
    let band = floor(uv.y * params.lines);
    let h = hash(vec2<f32>(band, tick), 0.0);
    let shift = (h - 0.5) * 2.0 * params.tear * 0.01 * peak * step(0.45, h);
    let ut = vec2<f32>(uv.x + shift, uv.y);
    let s = vec2<f32>(params.split * peak / max(frame.size.x, 1.0), 0.0);
    let a = vec4<f32>(from_at(ut + s).r, from_at(ut).g, from_at(ut - s).b, from_at(ut).a);
    let b = vec4<f32>(to_at(ut + s).r, to_at(ut).g, to_at(ut - s).b, to_at(ut).a);
    return mix(a, b, smoothstep(0.35, 0.65, progress));
}
