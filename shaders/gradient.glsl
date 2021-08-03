#ifdef VERTEX
vec4 position( mat4 transform_projection, vec4 vertex_position )
{
    return transform_projection * vertex_position;
}
#endif

#ifdef PIXEL
uniform float a = 1;
uniform float dir = 1;
vec4 effect( vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords )
{
    vec4 c = Texel(tex, texture_coords) * color;
    float cr = mix(texture_coords.y, texture_coords.x, 1-dir);
    return vec4(c.rgb, c.a * mix(cr, 1-cr, 1-a));
}
#endif 