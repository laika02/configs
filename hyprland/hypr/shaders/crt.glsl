  #version 300 es
  precision highp float;

  in vec2 v_texcoord;
  uniform sampler2D tex;
  out vec4 fragColor;

  const float PI = 3.14159265359;

  // Tuned to reduce shimmer/glitching while keeping the CRT look.
  const float BARREL = 0.14;
  const float CHROMA_PX = 0.9;
  const float SCANLINE_STRENGTH = 0.18;
  const float SHADOW_MASK_STRENGTH = 0.12;
  const float HALATION = 0.18;
  const float VIGNETTE = 1.20;
  const float BLACK_LEVEL = 0.010;
  const float CONTRAST = 1.08;

  vec3 toLinear(vec3 c) { return pow(c, vec3(2.2)); }
  vec3 toSRGB(vec3 c)   { return pow(max(c, 0.0), vec3(1.0 / 2.2)); }

  vec2 warp(vec2 uv) {
      vec2 p = uv * 2.0 - 1.0;
      float r2 = dot(p, p);
      p *= 1.0 + BARREL * r2 + 0.08 * r2 * r2;
      return p * 0.5 + 0.5;
  }

  vec2 clampUV(vec2 uv, vec2 texel) {
      // Keep taps inside the source texture to avoid edge garbage.
      return clamp(uv, texel * 0.5, vec2(1.0) - texel * 0.5);
  }

  void main() {
      vec2 uv = warp(v_texcoord);

      if (uv.x <= 0.0 || uv.x >= 1.0 || uv.y <= 0.0 || uv.y >= 1.0) {
          fragColor = vec4(0.0, 0.0, 0.0, 1.0);
          return;
      }

      vec2 res = vec2(textureSize(tex, 0));
      vec2 texel = 1.0 / res;

      // Radial chromatic aberration
      vec2 dirv = uv - vec2(0.5);
      float lenv = length(dirv);
      vec2 dir = (lenv > 0.0) ? (dirv / lenv) : vec2(0.0);
      vec2 ca = dir * CHROMA_PX * texel;

      float r = texture(tex, clampUV(uv + ca, texel)).r;
      float g = texture(tex, clampUV(uv, texel)).g;
      float b = texture(tex, clampUV(uv - ca, texel)).b;
      vec3 base = toLinear(vec3(r, g, b));

      // Halation / bloom (small blur kernel)
      vec3 blur = vec3(0.0);
      blur += toLinear(texture(tex, clampUV(uv + texel * vec2( 1.5, 0.0), texel)).rgb);
      blur += toLinear(texture(tex, clampUV(uv + texel * vec2(-1.5, 0.0), texel)).rgb);
      blur += toLinear(texture(tex, clampUV(uv + texel * vec2( 0.0, 1.5), texel)).rgb);
      blur += toLinear(texture(tex, clampUV(uv + texel * vec2( 0.0,-1.5), texel)).rgb);
      blur += toLinear(texture(tex, clampUV(uv + texel * vec2( 1.0, 1.0), texel)).rgb);
      blur += toLinear(texture(tex, clampUV(uv + texel * vec2(-1.0, 1.0), texel)).rgb);
      blur += toLinear(texture(tex, clampUV(uv + texel * vec2( 1.0,-1.0), texel)).rgb);
      blur += toLinear(texture(tex, clampUV(uv + texel * vec2(-1.0,-1.0), texel)).rgb);
      blur *= 0.125;

      float peak = max(max(base.r, base.g), base.b);
      float glow = smoothstep(0.55, 1.0, peak);

      vec3 color = base + blur * HALATION * glow;

      // Use output pixel coords to keep the pattern stable while content moves.
      float y = gl_FragCoord.y;
      float scan = 1.0 - SCANLINE_STRENGTH * (0.5 - 0.5 * cos(PI * y));
      color *= scan;

      // RGB shadow mask triads
      float x = gl_FragCoord.x;
      float triad = mod(floor(x), 3.0);
      vec3 mask = vec3(1.0 - SHADOW_MASK_STRENGTH);
      if (triad < 0.5) {
          mask.r = 1.0;
      } else if (triad < 1.5) {
          mask.g = 1.0;
      } else {
          mask.b = 1.0;
      }
      color *= mask;

      // Edge falloff / vignette
      vec2 d = uv - vec2(0.5);
      float vig = 1.0 - VIGNETTE * dot(d, d);
      color *= clamp(vig, 0.0, 1.0);

      // CRT-ish tone
      color = max(color - vec3(BLACK_LEVEL), vec3(0.0));
      color = clamp(color * CONTRAST, 0.0, 1.0);

      fragColor = vec4(toSRGB(color), 1.0);
  }
