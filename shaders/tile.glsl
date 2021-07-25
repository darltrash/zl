#ifdef VERTEX
vec4 position( mat4 transform_projection, vec4 vertex_position )
{
    return transform_projection * vertex_position;
}
#endif

#ifdef PIXEL
uniform vec4 scissors;
vec4 effect( vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords )
{
    return Texel(tex, texture_coords * scissors.xy + scissors.zw) * color;
}
#endif