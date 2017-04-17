varying lowp vec4 v_color;
varying lowp vec2 v_tex;
uniform sampler2D u_texture;

void main(void) {
    gl_FragColor = v_color * texture2D(u_texture, v_tex);
}
