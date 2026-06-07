use cyntax::MacroD;

fn main() {
    let src = include_str!("./test.glsl");
    let s = cyntax::preprocess_str(
        src,
        &[
            (
                "TEST_MACRO".to_string(),
                MacroD::Simple("EXPANDED_TEST_MACRO"),
            ),
            (
                "texelFetch".to_string(),
                MacroD::Complex(
                    vec!["__a__", "__b__"],
                    "wgpu_texelfetch(__a__, __b__, a, test, whatever)",
                ),
            ),
        ],
    );
    println!("{}", s);
}
