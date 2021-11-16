#[derive(Debug,NifStruct)]
#[module = "Xairo.RGBA"]
pub struct RGBA {
    pub red: f64,
    pub green: f64,
    pub blue: f64,
    pub alpha: f64
}

impl RGBA {
    pub fn to_tuple(self: &Self) -> (f64, f64, f64, f64) {
        (self.red, self.green, self.blue, self.alpha)
    }
}

