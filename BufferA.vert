void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
    vec2 uv = fragCoord.xy / iResolution.xy;

    vec4 state = texture(iChannel0, vec2(0.5));
    float paletteTarget = state.r;
    float wasMouseDown = state.g;
    float transitionAmount = state.b;

    vec2 mouseUV = iMouse.xy / iResolution.xy;
    bool isClicking = iMouse.z > 0.0;

    float distToSun = distance(mouseUV, vec2(0.5, 0.5));
    bool clickedOnSun = isClicking && (distToSun < 0.1);
    bool newClick = clickedOnSun && (wasMouseDown == 0.0);

    // Toggle on new click
    if (newClick) {
        paletteTarget = 1.0 - paletteTarget;
    }

    // Animate transition
    float speed = 0.01; // Smaller = slower transition
    transitionAmount = mix(transitionAmount, paletteTarget, speed);

    // Store updated state
    float mouseHold = isClicking ? 1.0 : 0.0;
    fragColor = vec4(paletteTarget, mouseHold, transitionAmount, 1.0);
}
