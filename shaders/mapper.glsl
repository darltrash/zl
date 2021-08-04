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
uniform vec4 luminance = vec4(1, 1, 1, 1);
uniform Image lumMap;
uniform Image MainTex;
void effect()
{
    vec4 c = Texel(MainTex, VaryingTexCoord.xy) * VaryingColor.rgba;
    vec4 p = mix(dark, light, dot(c.rgb, vec3(0.299, 0.587, 0.114)));
    vec4 o = mix(c, p, amount);
    love_Canvases[0] = o;
    love_Canvases[1] = Texel(lumMap, VaryingTexCoord.xy).rgba * vec4(1, 1, 1, luminance*c.a);
}
#endif 