shader_type spatial;
render_mode blend_mix,cull_back,diffuse_burley,specular_schlick_ggx
;
uniform vec3 uv1_offset = vec3(0.0, 0.0, 0.0);
uniform vec3 uv1_scale = vec3(1.0, 1.0, 1.0);
uniform int depth_min_layers = 8;
uniform int depth_max_layers = 16;
uniform vec2 depth_flip = vec2(1.0);
uniform float variation = 0.0;
varying float elapsed_time;
void vertex() {
	elapsed_time = TIME;
	UV = UV*uv1_scale.xy+uv1_offset.xy;
}
float dot2(vec2 x) {
	return dot(x, x);
}
float rand(vec2 x) {
    return fract(cos(mod(dot(x, vec2(13.9898, 8.141)), 3.14)) * 43758.5);
}
vec2 rand2(vec2 x) {
    return fract(cos(mod(vec2(dot(x, vec2(13.9898, 8.141)),
						      dot(x, vec2(3.4562, 17.398))), vec2(3.14))) * 43758.5);
}
vec3 rand3(vec2 x) {
    return fract(cos(mod(vec3(dot(x, vec2(13.9898, 8.141)),
							  dot(x, vec2(3.4562, 17.398)),
                              dot(x, vec2(13.254, 5.867))), vec3(3.14))) * 43758.5);
}
float param_rnd(float minimum, float maximum, float seed) {
	return minimum+(maximum-minimum)*rand(vec2(seed));
}
float param_rndi(float minimum, float maximum, float seed) {
	return floor(param_rnd(minimum, maximum + 1.0, seed));
}
vec3 rgb2hsv(vec3 c) {
	vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
	vec4 p = c.g < c.b ? vec4(c.bg, K.wz) : vec4(c.gb, K.xy);
	vec4 q = c.r < p.x ? vec4(p.xyw, c.r) : vec4(c.r, p.yzx);
	float d = q.x - min(q.w, q.y);
	float e = 1.0e-10;
	return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
}
vec3 hsv2rgb(vec3 c) {
	vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
	vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
	return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}
const vec4 p_o614297776026_albedo_color = vec4(0.509803951, 0.489644647, 0.325490206, 1.000000000);
const float p_o614297776026_metallic = 0.000000000;
const float p_o614297776026_roughness = 0.390000000;
const float p_o614297776026_emission_energy = 2.330000000;
const float p_o614297776026_normal = 1.000000000;
const float p_o614297776026_ao = 1.000000000;
const float p_o614297776026_depth_scale = 0.500000000;
const float p_o614348107187_gradient_pos[2] = float[]( 0.000000000, 0.493320614 );
const vec4 p_o614348107187_gradient_col[2] = vec4[]( vec4(0.251133561, 0.215686277, 0.564705908, 1.000000000), vec4(0.058823537, 0.391452223, 0.611764729, 1.000000000) );
const float p_o614566211485_default_in1 = 1.000000000;
const float p_o614566211485_default_in2 = 0.500000000;
const float p_o614331330456_translate_x = 0.000000000;
const float seed_o614314553241 = 0.000000000;
const float p_o614314553241_scale_x = 1.000000000;
const float p_o614314553241_scale_y = 30.000000000;
const float p_o614314553241_smoothness = 1.000000000;
const float p_o614314553241_interpolation = 1.000000000;
// #globals: colorize (o614348107187)
// #globals: math_2 (o614566211485)
float pingpong(float a, float b)
{
  return (b != 0.0) ? abs(fract((a - b) / (b * 2.0)) * b * 2.0 - b) : 0.0;
}
// #globals: noise_anisotropic (o614314553241)
float anisotropic(vec2 uv, vec2 size, float seed, float smoothness, float interpolation) {
	vec2 seed2 = rand2(vec2(seed, 1.0-seed));
	
	vec2 xy = floor(uv*size);
	vec2 offset = vec2(rand(seed2 + xy.y), 0.0);
	vec2 xy_offset = floor(uv * size + offset );
	float f0 = rand(seed2+mod(xy_offset, size));
	float f1 = rand(seed2+mod(xy_offset+vec2(1.0, 0.0), size));
	float mixer = clamp( (fract(uv.x*size.x+offset.x) -.5) / smoothness + 0.5, 0.0, 1.0 );
	float smooth_mix = smoothstep(0.0, 1.0, mixer);
	float linear = mix(f0, f1, mixer);
	float smoothed = mix(f0, f1, smooth_mix);
	
	return mix(linear, smoothed, interpolation);
}
vec4 o614348107187_gradient_gradient_fct(float x) {
  if (x < p_o614348107187_gradient_pos[0]) {
    return p_o614348107187_gradient_col[0];
  } else if (x < p_o614348107187_gradient_pos[1]) {
    return mix(p_o614348107187_gradient_col[0], p_o614348107187_gradient_col[1], ((x-p_o614348107187_gradient_pos[0])/(p_o614348107187_gradient_pos[1]-p_o614348107187_gradient_pos[0])));
  }
  return p_o614348107187_gradient_col[1];
}
void fragment() {
	float _seed_variation_ = variation;
	vec2 uv = fract(UV);

// #output0: noise_anisotropic (o614314553241)
float o614314553241_0_1_f = anisotropic(((uv)-vec2(p_o614331330456_translate_x, (elapsed_time*0.4))), vec2(p_o614314553241_scale_x, p_o614314553241_scale_y), (seed_o614314553241+fract(_seed_variation_)), p_o614314553241_smoothness, p_o614314553241_interpolation);

// #output0: translate (o614331330456)
vec4 o614331330456_0_1_rgba = vec4(vec3(o614314553241_0_1_f), 1.0);

// #code: math_2 (o614566211485)
float o614566211485_0_clamp_false = (dot((o614331330456_0_1_rgba).rgb, vec3(1.0))/3.0)*p_o614566211485_default_in2;
float o614566211485_0_clamp_true = clamp(o614566211485_0_clamp_false, 0.0, 1.0);
// #output0: math_2 (o614566211485)
float o614566211485_0_1_f = o614566211485_0_clamp_false;

// #output0: colorize (o614348107187)
vec4 o614348107187_0_1_rgba = o614348107187_gradient_gradient_fct(o614566211485_0_1_f);

	vec3 albedo_tex = vec3(1.0).rgb;
	albedo_tex = mix(pow((albedo_tex + vec3(0.055)) * (1.0 / (1.0 + 0.055)),vec3(2.4)),albedo_tex * (1.0 / 12.92),lessThan(albedo_tex,vec3(0.04045)));
	ALBEDO = albedo_tex*p_o614297776026_albedo_color.rgb;
	METALLIC = 1.0*p_o614297776026_metallic;
	ROUGHNESS = 1.0*p_o614297776026_roughness;
	NORMAL_MAP = vec3(0.5);
	NORMAL_MAP_DEPTH = p_o614297776026_normal;
	EMISSION = ((o614348107187_0_1_rgba).rgb)*p_o614297776026_emission_energy;
}



