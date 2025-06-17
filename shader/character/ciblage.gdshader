shader_type canvas_item;

uniform vec4 outline_color : source_color = vec4(1.0, 0.0, 0.0, 1.0); // rouge
uniform float progress : hint_range(0.0, 1.0) = 1.0;
uniform float thickness : hint_range(1.0, 5.0) = 1.0;

void fragment() {
    vec2 texel = vec2(1.0) / vec2(textureSize(TEXTURE, 0));
    vec4 tex_color = texture(TEXTURE, UV);

    float is_outline = 0.0;

    if (tex_color.a < 0.1) {
        // Parcours des pixels voisins
        for (int x = -1; x <= 1; x++) {
            for (int y = -1; y <= 1; y++) {
                if (x == 0 && y == 0) continue;

                vec2 offset = vec2(float(x), float(y)) * texel * thickness;
                float neighbor_alpha = texture(TEXTURE, UV + offset).a;

                if (neighbor_alpha > 0.1) {
                    is_outline = 1.0;
                }
            }
        }
    }

    if (is_outline > 0.5) {
        COLOR = mix(vec4(0.0), outline_color, progress);
    } else {
        COLOR = tex_color;
    }
}



//shader_type canvas_item;
//
//uniform vec4 outline_color : source_color = vec4(1.0, 0.0, 0.0, 1.0); // Couleur du contour
//uniform float progress : hint_range(0.0, 1.0) = 1.0;
//uniform float thickness : hint_range(1.0, 5.0) = 1.0;
//
//void fragment() {
    //vec2 texel = vec2(1.0) / vec2(textureSize(TEXTURE, 0));
    //vec4 tex_color = texture(TEXTURE, UV);
//
    //// On cible les pixels noirs opaques
    //bool is_black = tex_color.a > 0.1 && tex_color.rgb == vec3(0.0);
    //bool touches_transparent = false;
//
    //if (is_black) {
        //// Parcourt des pixels voisins
        //for (int x = -1; x <= 1; x++) {
            //for (int y = -1; y <= 1; y++) {
                //if (x == 0 && y == 0) continue;
//
                //vec2 offset = vec2(float(x), float(y)) * texel * thickness;
                //float neighbor_alpha = texture(TEXTURE, UV + offset).a;
//
                //if (neighbor_alpha < 0.1) {
                    //touches_transparent = true;
                //}
            //}
        //}
    //}
//
    //if (is_black && touches_transparent) {
        //COLOR = mix(tex_color, outline_color, progress);
    //} else {
        //COLOR = tex_color;
    //}
//}
