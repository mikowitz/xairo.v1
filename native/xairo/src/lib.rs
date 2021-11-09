use rustler::{Atom, Env, ResourceArc, Term};

mod xairo_image;
use xairo_image::XairoImage;

mod atoms;


type ImageArc = ResourceArc<XairoImage>;

#[rustler::nif]
fn new_image(width: i32, height: i32) -> Result<ImageArc, Atom> {
    match XairoImage::new(width, height) {
        Ok(image) => Ok(ResourceArc::new(image)),
        Err(err) => Err(err)
    }
}

#[rustler::nif]
fn save_image(image: ImageArc, filename: String) -> Result<ImageArc, Atom> {
    match image.save(filename) {
        Ok(_) => Ok(image),
        Err(err) => Err(err)
    }
}

rustler::init!(
    "Elixir.Xairo.Native",
    [
        new_image,
        save_image,
    ],
    load=on_load
);

fn on_load(env: Env, _info: Term) -> bool {
    rustler::resource!(XairoImage, env);
    true
}
