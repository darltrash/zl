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
uniform vec2 resolution;
uniform float scale = 1;
uniform Image canvas;

vec4 effect( vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords )
{
    vec4 c = Texel(canvas, screen_coords/(resolution*scale)) * color;
    vec4 m = mix(dark, light, dot(c.rgb, vec3(0.299, 0.587, 0.114)));
    vec4 o = mix(c, m, amount);
    o.a = c.a * Texel(tex, texture_coords).a;
    return o;
}
#endif 