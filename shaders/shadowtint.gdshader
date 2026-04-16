shader_type spatial;
render_mode ambient_light_disabled;
//render_mode world_vertex_coords;
uniform vec3 color:source_color;
uniform sampler2D shadow_mask2d:source_color,repeat_enable,filter_linear;
uniform sampler3D shadow_mask3d:source_color,repeat_enable,filter_linear;
uniform sampler2D color_gradient:source_color;
uniform vec3 offset;
uniform float scale=0.75;

varying vec3 world_pos;
varying vec3 local_pos;
varying vec3 local_normal;
varying vec3 cam_pos;

vec4 triplanar_texture(sampler2D p_sampler, vec3 p_weights, vec3 p_triplanar_pos) {
	vec4 samp = vec4(0.0);
	samp += texture(p_sampler, p_triplanar_pos.xy) * p_weights.z;
	samp += texture(p_sampler, p_triplanar_pos.xz) * p_weights.y;
	samp += texture(p_sampler, p_triplanar_pos.zy * vec2(-1.0, 1.0)) * p_weights.x;
	return samp;
}

vec4 sample_text3d(sampler3D mask, vec3 pos){
	return texture(mask, pos);
}


vec3 tile(vec3 p, float size) {
    return mod(p, size) - size * 0.5;
}

vec4 volume_march(vec3 ro, vec3 rd, int steps, float stepd){
	float sample_scale=scale;
	ro+=rd*40.0;
	vec4 value=vec4(0.0);
	for (int i=0;i<steps;i++){
		value+=sample_text3d(shadow_mask3d,ro*sample_scale)*stepd;
		if (value.r>=0.9){
			break;
		}
		ro+=rd*stepd;
	}
	return value;
}


void vertex() {
	local_pos=VERTEX;
	world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	local_normal=NORMAL;
	cam_pos=CAMERA_POSITION_WORLD;
}

void fragment() {
	ALBEDO=color;
	if (abs(ALBEDO.r)<=0.0001) ALBEDO.r=0.0001;
	if (abs(ALBEDO.g)<=0.0001) ALBEDO.g=0.0001;
	if (abs(ALBEDO.b)<=0.0001) ALBEDO.b=0.0001;

	SPECULAR=0.0;
	//AO=0.0;
	//EMISSION=vec3(0.01);
	//IRRADIANCE=vec4(0.0);
}

void light() {
	float NdotL = max(dot(NORMAL, LIGHT), 0.0);
	float lit_intensity=smoothstep(0.0,0.5,NdotL*ATTENUATION);
	//toon light, relatively flat color, no smooth blur edge
	vec3 light_col=lit_intensity * LIGHT_COLOR / PI;

	vec3 shadow_col=vec3(0.0);
	{///////////////////////YOUR COLOR LOGIC IN HERE//////////////////
		//SOME EXAMPLES:

		//ray march polka dots
		//vec3 ro=cam_pos+vec3(0.0,TIME*0.0,0.0);
		//vec3 rd=normalize(world_pos-cam_pos);
		//float ray_march_val=volume_march(ro,rd,100,0.1).r;
		//shadow_col=mix(vec3(0.03,0.0,0.02),vec3(0.25,0.01,0.01),ray_march_val);

		//RED shadow
		shadow_col=vec3(1.0,0.0,0.0);

		//triplanar texture
		//shadow_col=triplanar_texture(shadow_mask2d,abs(local_normal),local_pos).rgb*0.1;
	}
	//TODO: handle cases where albedo.rgb is0
	//divide by albedo to cancel out all color. may be weird when albedo.rgb is 0
	//due to division by 0. could try to avoid albedo becoming absolute 0 in fragment
	vec3 _shadow_col=shadow_col/ALBEDO;

	if (LIGHT_IS_DIRECTIONAL)
		DIFFUSE_LIGHT+=mix(_shadow_col,light_col,smoothstep(0.01,1.0,lit_intensity));
	else//non directional light can be a bit funky
		DIFFUSE_LIGHT+=mix(_shadow_col,light_col,smoothstep(0.01,1.0,lit_intensity))*ATTENUATION;
}
