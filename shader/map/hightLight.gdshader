//shader_type canvas_item;
//
//void fragment() {
    //// On récupère la couleur de la texture
    //vec4 tex_color = texture(TEXTURE, UV);
    //
    //// On applique une teinte bleue : on garde l'alpha, mais on force le bleu
    //// Tu peux ajuster l'intensité du bleu ici
    //float blue_strength = 1.0;
    //vec3 blue_tint = vec3(0.0, 0.0, blue_strength);
//
    //// Mélange la couleur d'origine avec la teinte bleue
    //// Le facteur de mix ici est à 0.8 pour que la teinte bleue domine
    //COLOR = vec4(mix(tex_color.rgb, blue_tint, 0.4), tex_color.a);
//}
shader_type canvas_item;

uniform float mix_amount : hint_range(0.0, 1.0) = 0.3; // 0 = pas de teinte, 1 = entièrement bleue
uniform vec3 tint_color = vec3(0.0, 0.0, 1.0); // Teinte bleue par défaut

void fragment() {
    vec4 tex_color = texture(TEXTURE, UV);
    vec3 tinted = mix(tex_color.rgb, tint_color, mix_amount);
    COLOR = vec4(tinted, tex_color.a);
}
