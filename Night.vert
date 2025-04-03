
float rand(vec2 co) {
        return fract(sin(dot(co, vec2(12.9898, 78.233))) * 43758.5453);
    }

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    // fragColor : the pixel's output color.
    // fragCoord : screen pixel coordinates (in pixels), like (0,0) at bottom left.
    
    vec2 uv = fragCoord.xy / iResolution.xy;  //transformed pixel coordinates
    vec3 backgroundcolor = mix( vec3(0.553,0.749,0.949),  vec3(0.055,0.118,0.306) , sqrt(uv.y)*1.2); ; //  Create color with RGB
   //vec3 backgroundcolor = vec3(0);
    float t = iTime;
    
    
    // Table of light circle centre positions (values between 0 and 1)
    vec2 centers[6];
    centers[0] = vec2(0.5) + 0.2 * vec2(cos(t), sin(t)); // center + radius * define rotation movement   
    centers[1] = vec2(0.5) + 0.2 * vec2(cos(t + 2.0), sin(t + 2.0));
    centers[2] = vec2(0.5) + 0.2 * vec2(cos(t + 4.0), sin(t + 4.0));
    centers[3] = vec2(0.5) + 0.25 * vec2(cos(t), sin(t)); //
    centers[4] = vec2(0.5) + 0.25 * vec2(cos(t + 2.0), sin(t + 2.0));
    centers[5] = vec2(0.5) + 0.25 * vec2(cos(t + 4.0), sin(t + 4.0));    
  
   
    // Synchronised pulse: same value for all stars
    float pulse = 0.003 + 0.005 * sin(t * 1.0); // all the stars are pulsating together
    
    for (int i = 0; i < 6; i++) {
        vec2 fromCenterToPoint = uv - centers[i]; // Vector between a point and the center
        fromCenterToPoint.x *= iResolution.x / iResolution.y; // Corrects the ratio for a true circle
        float fromCenterToPointDistance = length(fromCenterToPoint); //Distance between uv and center
        
        float m = pulse /fromCenterToPointDistance; //To simulate the light
        backgroundcolor += m; //Addition of the color
    }
    
    
          // --- SMALL FIXED TWINKLING STARS ---
    float starDensity = 40.0;
    vec2 gridUV = floor(uv * starDensity) / starDensity;
    
    float sparkle = rand(gridUV);
    float starThreshold = 0.9;

    if (sparkle > starThreshold) {
        float localTime = t * 5.0 + sparkle * 10.0;
        
        // Introduces a random frequency and phase per star
        float blinkSpeed = mix(2.0, 6.0, rand(gridUV + 1.234)); // entre 2 et 6
        float blinkPhase = rand(gridUV + 4.567) * 6.28;         // entre 0 et 2*PI

        float blink = 0.5 + 0.5 * sin(t * blinkSpeed + blinkPhase); // fluctuates between 0.0 and 1.0

        float distToStar = length(fract(uv * starDensity) - 0.5);
        float star = smoothstep(0.06, 0.0, distToStar) * blink;
        backgroundcolor += vec3(star);
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
