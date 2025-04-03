void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    // fragColor : the pixel's output color.
    // fragCoord : screen pixel coordinates (in pixels), like (0,0) at bottom left.
    
    vec2 uv = fragCoord.xy / iResolution.xy;  //transformed pixel coordinates
    vec3 backgroundcolor = mix( vec3(0.114,0.369,0.569), vec3(0.008,0.118,0.455) , sqrt(uv.y)); ; //  Create color with RGB
    
    float t = iTime;
    
    // Table of light circle centre positions (values between 0 and 1)
    vec2 centers[3];
    centers[0] = vec2(0.3, 0.5);
    centers[1] = vec2(0.7, 0.6);
    centers[2] = vec2(0.5, 0.3);

    for (int i = 0; i < 3; i++) {
        vec2 fromCenterToPoint = uv - centers[i]; //Vector  between a point and the center
        fromCenterToPoint.x *= iResolution.x / iResolution.y; // Corrects the ratio for a true circle
        float fromCenterToPointDistance = length(fromCenterToPoint); //Distance between uv and center

        float m = 0.01/fromCenterToPointDistance; //To simulate the light
        backgroundcolor += m; //Addition of the color
    }
    
    fragColor = vec4(backgroundcolor, 1.0); // Define the color
    
}
