use anyhow::Result;
use serde::Deserialize;
use v_utils::{io::ExpandedPath, macros::MyConfigPrimitives};

#[derive(Debug, Default, derive_new::new, Clone, MyConfigPrimitives)]
pub struct AppConfig {
	pub channels: Channels,
}
// In the perfect world would pick up the list of channels and their names from the config file, then create the cli bindings based on them. This feels redundant.
#[derive(Default, Clone, derive_new::new, Debug, MyConfigPrimitives)]
pub struct Channels {
	pub wtt: isize,
	pub journal: isize,
	pub alerts: isize,
}

impl AppConfig {
	pub fn read(path: ExpandedPath) -> Result<Self, config::ConfigError> {
		let builder = config::Config::builder().add_source(config::File::with_name(&path.to_string()));

		let settings: config::Config = builder.build()?;
		let settings: Self = settings.try_deserialize()?;

		Ok(settings)
	}
}
