void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    // fragColor : the pixel's output color.
    // fragCoord : screen pixel coordinates (in pixels), like (0,0) at bottom left.
    
    vec2 uv = fragCoord.xy / iResolution.xy;  //transformed pixel coordinates
    vec3 backgroundcolor = mix( vec3(0.114,0.369,0.569), vec3(0.008,0.118,0.455) , sqrt(uv.y)); ; //  Create color with RGB
    ///////vec3 backgroundcolor = vec3(0);
    float t = iTime;
    
    
    // Table of light circle centre positions (values between 0 and 1)
    vec2 centers[6];
    centers[0] = vec2(0.5) + 0.2 * vec2(cos(t), sin(t)); // center + rayon * define rotation movement
    centers[1] = vec2(0.5) + 0.3 * vec2(cos(t + 2.0), sin(t + 2.0));
    centers[2] = vec2(0.5) + 0.25 * vec2(cos(t + 4.0), sin(t + 4.0));
  
   
    // Synchronised pulse: same value for all stars
    float pulse = 0.01 + 0.005 * sin(t * 2.0); // all the stars are pulsating together
    
    for (int i = 0; i < 3; i++) {
        vec2 fromCenterToPoint = uv - centers[i]; // Vector  between a point and the center
        fromCenterToPoint.x *= iResolution.x / iResolution.y; // Corrects the ratio for a true circle
        float fromCenterToPointDistance = length(fromCenterToPoint); //Distance between uv and center
        
        float m = pulse /fromCenterToPointDistance; //To simulate the light
        backgroundcolor += m; //Addition of the color
    }
    
    // --- CRESCENT MOON IN THE CENTRE ---
    vec2 moonCenter = vec2(0.9, 0.5);
    vec2 moonUV = uv;
    moonUV.x *= iResolution.x / iResolution.y; // Ratio correction for round shapes

    float radius = 0.07;

    float distToMainCircle = length(moonUV - moonCenter);
    float distToCutCircle  = length(moonUV - (moonCenter + vec2(0.02, 0.0)));

    float moonShape = smoothstep(radius, radius - 0.005, distToMainCircle)
                    * (1.0 - smoothstep(radius, radius - 0.005, distToCutCircle));

    vec3 moonColor = vec3(1.000,1.000,0.761); // Slightly yellow moon
    backgroundcolor = mix(backgroundcolor, moonColor, moonShape);

    
    fragColor = vec4(backgroundcolor, 1.0); // Define the color
    
}
