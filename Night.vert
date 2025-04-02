void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    // fragColor : the pixel's output color.
    // fragCoord : screen pixel coordinates (in pixels), like (0,0) at bottom left.
    
    vec2 p = fragCoord.xy / iResolution.xy; //P pixel position
    vec3 col = mix( vec3(0.114,0.369,0.569), vec3(0.008,0.118,0.455), sqrt(p.y)); ; //  Create color with RGB
    
    fragColor = vec4(col, 1.0); // Define the color
}