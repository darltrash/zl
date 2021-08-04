#ifdef VERTEX
vec4 position( mat4 transform_projection, vec4 vertex_position )
{
    return transform_projection * vertex_position;
}
#endif

#ifdef PIXEL
uniform vec4 dark = vec4(0, 0, 59/255, 1);
uniform vec4 light = vec4(230/255, 189/255, 1, 1);
uniform float amount = 0.3;
vec4 effect( vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords )
{
    vec4 c = Texel(tex, texture_coords) * color;
    vec4 o = mix(dark, light, dot(c.rgb, vec3(0.299, 0.587, 0.114)));
    return mix(c, o, amount);
}
#endif 