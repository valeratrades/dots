use lazy_static::lazy_static;

lazy_static! {
	pub static ref INIT: () = {
		color_eyre::install().unwrap();
	};
}
