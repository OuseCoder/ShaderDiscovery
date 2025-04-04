#define S(a,b,t) smoothstep(a,b,t)
#define ROT -0.785398
#define ZOOM .25
#define STAR_SPEED 2.



float N21(vec2 p) {
    p = fract(p * vec2(233.34, 851.73));
    p += dot(p, p + 23.45);
    return fract(p.x * p.y);
}

float DistLine(vec2 p, vec2 a, vec2 b) {
    vec2 pa = p - a;
    vec2 ba = b - a;
    float t = clamp(dot(pa, ba) / dot(ba, ba), 0.0, 1.0);
    return length(pa - ba * t);
}

float DrawLine(vec2 p, vec2 a, vec2 b) {
    float d = DistLine(p, a, b);
    float m = S(0.0025, 0.00001, d);
    float d2 = length(a - b);
    m *= S(1.0, 0.5, d2) + S(0.04, 0.03, abs(d2 - 0.75));
    return m;
}

float ShootingStar(vec2 uv) {    
    vec2 gv = fract(uv) - 0.5;
    vec2 id = floor(uv);
    
    float h = N21(id);
    
    float line = DrawLine(gv, vec2(0.0, h), vec2(0.125, h));
    float trail = S(0.14, 0.0, gv.x);
	
    return line * trail;
}




float rand(vec2 co) {
        return fract(sin(dot(co, vec2(12.9898, 78.233))) * 43758.5453);
}
    

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    // fragColor : the pixel's output color.
    // fragCoord : screen pixel coordinates (in pixels), like (0,0) at bottom left.
    
    vec2 uv = fragCoord.xy / iResolution.xy;  //transformed pixel coordinates
    
    
    vec3 horizonColor = vec3(1.0, 0.5, 0.2); // warm orange at the bottom
    vec3 horizonUpColor = vec3(0.965,0.945,0.933); // light orange
    vec3 midColor = vec3(0.553,0.749,0.949); // transition to blue/white
    vec3 topColor = vec3(0.055,0.118,0.306); // very dark sky / night
    
    // Interpolation in 3 stages
    vec3 bottom = mix(horizonColor, horizonUpColor, sqrt(uv.y)*0.5);
    vec3 bottomToMid = mix(bottom, midColor, sqrt(uv.y)*1.2);
    vec3 fullGradient = mix(bottomToMid, topColor, sqrt(uv.y)*1.2);

    vec3 backgroundcolor = fullGradient;
    
   //vec3 backgroundcolor = vec3(0);
    float t = iTime;
    
    
              // --- SMALL FIXED TWINKLING STARS ---
    float starDensity = 40.0; //Define the number of stars
    vec2 gridUV = floor(uv * starDensity) / starDensity;
    
    float sparkle = rand(gridUV);
    float starThreshold = 0.85; // Adjust this threshold to get more or fewer stars
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
    
    
    //STRANGE FORM GRAVITATING
    // Table of light circle centre positions (values between 0 and 1)
    vec2 centers[6];
    centers[0] = vec2(0.5) + 0.2 * vec2(cos(t), sin(t)); // center + radius * define rotation movement   
    centers[1] = vec2(0.5) + 0.2 * vec2(cos(t + 2.0), sin(t + 2.0));
    centers[2] = vec2(0.5) + 0.2 * vec2(cos(t + 4.0), sin(t + 4.0));
    centers[3] = vec2(0.5) + 0.25 * vec2(cos(t), sin(t)); 
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
    

     // --- ORANGE FIXED STAR ---
    vec2 sunCenter = vec2(0.5, 0.5); // position of the "sun"
    vec2 fromSun = uv - sunCenter;
    fromSun.x *= iResolution.x / iResolution.y;
    float distToSun = length(fromSun);

    float orangeGlow = 0.02 / distToSun;
    vec3 orangeColor = vec3(0.953,0.494,0.071); // orange color

    backgroundcolor += orangeColor * orangeGlow;
    
    
      

    // --- SHOOTING STARS ---
    vec2 shootingUV = (fragCoord - 0.5 * iResolution.xy) / iResolution.y;
    float t2 = iTime * STAR_SPEED;

    // Star 1
    vec2 rv1 = shootingUV - vec2(t2, -t2);
    rv1.x *= 1.1;
    rv1 *= mat2(cos(3.0 * ROT), -sin(3.0 * ROT), sin(3.0 * ROT), cos(3.0 * ROT));
    rv1 *= ZOOM * 0.9;

    // Star 2
    vec2 rv2 = shootingUV + vec2(t2 * 1.2, t2 * 1.2);
    rv2.x *= 1.1;
    rv2 *= mat2(cos(ROT), -sin(ROT), sin(ROT), cos(ROT));
    rv2 *= ZOOM * 1.1;

    float star1 = ShootingStar(rv1);
    float star2 = ShootingStar(rv2);

   // vec3 shootingColor = vec3(1.0, 1.0, 0.8) * clamp(star1 + star2, 0.0, 1.0);
     vec3 shootingColor = vec3(1.000,0.639,0.639) * clamp(star1 + star2, 0.0, 1.0);
   
    backgroundcolor += shootingColor;

    
    

       
    fragColor = vec4(backgroundcolor, 1.0); // Define the color  
}
