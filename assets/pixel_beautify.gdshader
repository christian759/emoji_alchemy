shader_type canvas_item;

uniform vec4 base_color : source_color = vec4(0.2, 0.2, 0.25, 1.0);
uniform float bevel_size : hint_range(0.0, 0.5) = 0.12;
uniform float shine_speed : hint_range(0.0, 5.0) = 1.0;
uniform float shine_intensity : hint_range(0.0, 1.0) = 0.0;

void fragment() {
    vec2 uv = UV;
    vec4 color = base_color;
    
    // Chunkier pixel-art bevel
    float edge_l = step(uv.x, bevel_size);
    float edge_r = step(1.0 - bevel_size, uv.x);
    float edge_t = step(uv.y, bevel_size);
    float edge_b = step(1.0 - bevel_size, uv.y);
    
    // Bold Top-Left Highlight
    if (edge_l > 0.5 || edge_t > 0.5) {
        color.rgb += 0.25; // Brighter highlight
    }
    
    // Bold Bottom-Right Shadow
    if (edge_r > 0.5 || edge_b > 0.5) {
        color.rgb -= 0.25; // Darker shadow
    }
    
    // Bold Corner intersections
    if (edge_l > 0.5 && edge_t > 0.5) color.rgb += 0.15;
    if (edge_r > 0.5 && edge_b > 0.5) color.rgb -= 0.15;
    
    // Intense Shimmer effect
    float shine = step(0.96, sin(uv.x + uv.y + TIME * shine_speed));
    color.rgb += shine * shine_intensity * 1.5; // More intense shimmer
    
    COLOR = color;
}
