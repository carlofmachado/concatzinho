struct Params { bars: f32, angle: f32, blur: f32, specular: f32, stagger: f32 }

// Adapted from Drift by CutWire Studios (GPL-3.0-or-later), transitions/linear_blinds.

fn transition(uv: vec2<f32>, progress: f32) -> vec4<f32> {
    let rad = radians(params.angle);
    let dir = vec2<f32>(cos(rad), sin(rad));
    let stagger = params.stagger * 0.01;
    let coord = dot(uv - vec2<f32>(0.5), dir) + 0.5;
    let idx = floor(coord * params.bars);
    let cell = fract(coord * params.bars);
    let t0 = clamp(progress * (1.0 + stagger) - hash(vec2<f32>(idx, 0.0), 3.0) * stagger, 0.0, 1.0);
    // Past both ends of the slat, so the first and last frames are clean.
    let t = mix(-0.07, 1.07, t0);
    let m = 1.0 - smoothstep(t - 0.06, t + 0.06, cell);
    let peak = 1.0 - abs(progress * 2.0 - 1.0);
    let amt = params.blur * 0.01 * peak * 0.04;
    var b = vec4<f32>(0.0);
    for (var i = 0; i < 8; i++) {
        let k = f32(i) / 7.0 - 0.5;
        b += to_at(uv + dir * k * amt);
    }
    b = b / 8.0;
    let c = mix(from_at(uv), b, m);
    let edge = 1.0 - smoothstep(0.0, 0.1, abs(cell - t));
    let lit = to_display(c.rgb) + vec3<f32>(edge * params.specular * 0.01 * peak * c.a);
    return vec4<f32>(from_display(lit), c.a);
}
