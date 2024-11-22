shader_type canvas_item;

uniform float time : hint_range(0.0, 10.0);

void fragment() {
    // Crear un degradado de color para simular llamas
    vec4 fire_color = vec4(sin(TIME + time) * 0.5 + 0.5, 0.3, 0.1, 1.0); // Amarillo-anaranjado
    COLOR = fire_color;
}
