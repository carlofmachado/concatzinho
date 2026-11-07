struct Params { amount: f32, hue: f32, angle: f32, speed: f32, softness: f32, flicker: f32 }

// Adapted from Drift by CutWire Studios (GPL-3.0-or-later), effects/light_leak.

fn d_hsv(c: vec3<f32>) -> vec3<f32> {
    let p = abs(fract(vec3<f32>(c.x) + vec3<f32>(1.0, 2.0 / 3.0, 1.0 / 3.0)) * 6.0 - vec3<f32>(3.0));
    return c.z * mix(vec3<f32>(1.0), clamp(p - vec3<f32>(1.0), vec3<f32>(0.0), vec3<f32>(1.0)), c.y);
}

fn effect(uv: vec2<f32>) -> vec4<f32> {
    let src = sample(uv);
    let p = uv - vec2<f32>(0.5);
    let a = radians(params.angle);
    let axis = p.x * cos(a) + p.y * sin(a);
    // The leak sweeps past and wraps off frame, never as a jump on screen.
    let travel = fract(frame.time * params.speed * 0.01 * 0.15);
    let pos = mix(-0.9, 0.9, travel);
    let soft = max(params.softness * 0.01, 0.02);
    let band = exp(-pow((axis - pos) / soft, 2.0));
    let band2 = exp(-pow((axis - pos - 0.18) / (soft * 0.4), 2.0)) * 0.6;
    let flick = 1.0 - params.flicker * 0.005 * (0.5 + 0.5 * sin(frame.time * 37.0));
    let leak = d_hsv(vec3<f32>(params.hue / 360.0, 0.75, 1.0));
    let add = clamp(leak * (band + band2) * params.amount * 0.01 * flick, vec3<f32>(0.0), vec3<f32>(1.0));
    // Screened over the display level, a highlight past white carried on past it.
    let d = to_display(src.rgb);
    let lit = d + add * (vec3<f32>(1.0) - clamp(d, vec3<f32>(0.0), vec3<f32>(1.0)));
    return vec4<f32>(from_display(lit), src.a);
}
