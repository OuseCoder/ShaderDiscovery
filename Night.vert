#define S(a,b,t) smoothstep(a,b,t)
#define ROT -0.785398
#define ZOOM .5
#define STAR_SPEED 2.0


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


// Create the sky color
vec3 getBackgroundColor(vec2 uv, float transitionAmount) {

    // --- PALETTE A: Blue night sky
    vec3 paletteA = mix(vec3(0.553, 0.749, 0.949), vec3(0.055, 0.118, 0.306), sqrt(uv.y) * 1.2);

    // --- PALETTE B : orange sky to blue sky
    vec3 horizonColor = vec3(1.0, 0.5, 0.2); // warm orange at the bottom
    vec3 horizonUpColor = vec3(0.965,0.945,0.933); // light orange
    vec3 midColor = vec3(0.553,0.749,0.949); // transition to blue/white
    vec3 topColor = vec3(0.055,0.118,0.306); // very dark sky / night
    
    // Interpolation in 3 stages
    vec3 bottom = mix(horizonColor, horizonUpColor, sqrt(uv.y)*0.5);
    vec3 bottomToMid = mix(bottom, midColor, sqrt(uv.y)*1.2);
    vec3 paletteB  = mix(bottomToMid, topColor, sqrt(uv.y)*1.2);

     // Interpolation douce contrôlée par le buffer
    return mix(paletteB, paletteA, transitionAmount);

}

vec3 drawTwinklingStars(vec2 uv, float t) {

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
        return vec3(star);
    }
    return vec3(0.0);

}


vec3 drawGravitatingForms(vec2 uv, float t) {

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
    vec3 glow = vec3(0.0);
    
    for (int i = 0; i < 6; i++) {
        vec2 fromCenterToPoint = uv - centers[i]; // Vector between a point and the center
        fromCenterToPoint.x *= iResolution.x / iResolution.y; // Corrects the ratio for a true circle
        float fromCenterToPointDistance = length(fromCenterToPoint); //Distance between uv and center
        
        float m = pulse /fromCenterToPointDistance; //To simulate the light
        glow += m; //Addition of the color
    }
    
    return glow ;
}



vec3 drawSunGlow(vec2 uv) {
     // --- ORANGE FIXED STAR ---
    vec2 sunCenter = vec2(0.5, 0.5); // position of the "sun"
    vec2 fromSun = uv - sunCenter;
    fromSun.x *= iResolution.x / iResolution.y;
    float distToSun = length(fromSun);

    float orangeGlow = 0.04 / distToSun;
    vec3 orangeColor = vec3(0.953,0.494,0.071); // orange color

    return orangeColor * orangeGlow;

}


vec3 drawMagicEffect(vec2 uv, float t, float activated) {
    if (activated > 0.01) {
        // Magic effect
        float dist = distance(uv, vec2(0.5, 0.5)); // central position (the ‘sun’)
        float magic = smoothstep(0.2, 0.0, dist) * sin(iTime * 7.0) * activated;
        return vec3(1.000,0.302,0.000) * magic; //Define the color change
    } 
    return vec3(0.0);
}




vec3 drawShootingStars(vec2 fragCoord, float t, float transitionAmount) {

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
    float stars = clamp(star1 + star2, 0.0, 1.0);


    // Read the transition factor from the buffer
    transitionAmount = texture(iChannel0, vec2(0.5)).b;

    // Original pink colour
    vec3 colorA = vec3(1.000, 0.639, 0.639);
    // Couleur autre pour la version nuit
    vec3 colorB =  vec3(0.000,0.298,1.000);

    // Interpolation between the two colours
    vec3 shootingColor = mix(colorA, colorB, transitionAmount) * stars;

    return shootingColor; 

}
    

void mainImage( out vec4 fragColor, in vec2 fragCoord ) {

    vec2 uv = fragCoord.xy / iResolution.xy;  //transformed pixel coordinates
    float t = iTime;
    
    // Read buffer data
    vec4 paletteData = texture(iChannel0, vec2(0.5));
    float transitionAmount = paletteData.b;
    float activated = texture(iChannel0, vec2(0.5)).r; // Read the state from Buffer A to create a purple effect
    
    vec3 backgroundcolor = vec3(0.0);
    backgroundcolor += getBackgroundColor(uv, transitionAmount); // Create the sky
    backgroundcolor += drawTwinklingStars(uv, t); // Create the stars
    backgroundcolor += drawGravitatingForms(uv, t); // Create the white/black forms
    backgroundcolor += drawSunGlow(uv); // Create the glowing sun
    backgroundcolor += drawShootingStars(fragCoord, t, transitionAmount); // Create the shooting stars
    backgroundcolor += drawMagicEffect(uv, t, activated); // Create the magic effect when clicking on the sun
    fragColor = vec4(backgroundcolor, 1.0); // Define the color  
}
