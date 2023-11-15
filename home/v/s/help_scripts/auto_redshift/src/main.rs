#[allow(unused_variables)]
use chrono::prelude::*;
use std::process::Command;

#[derive(Debug)]
struct Bedtime {
	hours: u32,
	minutes: u32,
}
impl From<String> for Bedtime {
	fn from(s: String) -> Self {
		let split: Vec<_> = s.split(':').collect();
		assert!(split.len() == 2, "ERROR: bedtime should be supplied in the format: \"%H:%M\"");
		let hours: u32 = split[0].parse().unwrap();
		let minutes: u32 = split[1].parse().unwrap();
		Bedtime { hours, minutes }
	}
}

fn main() {
	let args: Vec<String> = std::env::args().collect();
	assert!(args.len() == 2, "ERROR: provide one and only one argument, being the bedtime in format: '%H:%M'");
	let bedtime: Bedtime = args[1].clone().into();

	// dancing with tambourine to get into the 30m cycle
	let good_minutes_small = bedtime.minutes % 30;
	let good_minutes_big = good_minutes_small + 30;
	let m = Utc::now().minute();
	let mut _wait_to_sync_m = 0;
	if m <= good_minutes_small && good_minutes_small != 0 {
		_wait_to_sync_m = good_minutes_small - m;
	} else if m <= good_minutes_big {
		_wait_to_sync_m = good_minutes_big - m;
	} else {
		_wait_to_sync_m = good_minutes_small + 60 - m;
	}
	set_redshift(&bedtime);
	std::thread::sleep(std::time::Duration::from_secs(_wait_to_sync_m as u64 * 60));
	loop {
		set_redshift(&bedtime);
		std::thread::sleep(std::time::Duration::from_secs(30 * 60));
	}
}

fn set_redshift(bedtime: &Bedtime) {
	let nm = Utc::now().hour() * 60 + Utc::now().minute();
	let bm = bedtime.hours * 60 + bedtime.minutes;
	// by default we have brightness=1 and temperature=6500. With every level we decrease them by 0.0275 and 210 accordingly. Max redshift is level 20, where we arrive at 0.45 and 2300 accordingly.
	let mut redshift: u32 = 0;

	// shift everything bm minutes back
	// in python would be `(nm - bm) % 24`, but rust doesn't want to exhibit desired behaviour with % on negative numbers
	let mut now_shifted = nm as i32 - bm as i32;
	if now_shifted < 0 {
		now_shifted += 24 * 60;
	}

	if now_shifted <= 4 * 60 {
		redshift = 20;
	} else if now_shifted >= 20 * 60 {
		redshift = ((now_shifted as f32 / 60.0 - 20 + 0.5) * 5.0) as u32;
	}

	if redshift != 0 {
		let temperature: f32 = 6500.0 - redshift as f32 * 210.0;
		let brightness: f32 = 1.0 - redshift as f32 * 0.0275;

		let extra_characters: &[_] = &['(', ')', ','];
		let current_temperature_bytes = Command::new("sh")
			.arg("-c")
			.arg("gdbus call -e -d net.zoidplex.wlr_gamma_service -o /net/zoidplex/wlr_gamma_service -m net.zoidplex.wlr_gamma_service.temperature.get".to_owned())
			.output()
			.unwrap()
			.stdout;
		let current_temperature = String::from_utf8_lossy(&current_temperature_bytes)
			.trim()
			.to_string()
			.trim_matches(extra_characters)
			.parse()
			.unwrap();
		let current_brightness_bytes = Command::new("sh")
			.arg("-c")
			.arg("gdbus call -e -d net.zoidplex.wlr_gamma_service -o /net/zoidplex/wlr_gamma_service -m net.zoidplex.wlr_gamma_service.brightness.get".to_owned())
			.output()
			.unwrap()
			.stdout;
		let current_brightness = String::from_utf8_lossy(&current_brightness_bytes)
			.trim()
			.to_string()
			.trim_matches(extra_characters)
			.parse()
			.unwrap();

		if temperature < current_temperature && brightness < current_brightness {
			let _ = Command::new("sh")
					.arg("-c")
					.arg(format!("gdbus call -e -d net.zoidplex.wlr_gamma_service -o /net/zoidplex/wlr_gamma_service -m net.zoidplex.wlr_gamma_service.temperature.set {} && gdbus call -e -d net.zoidplex.wlr_gamma_service -o /net/zoidplex/wlr_gamma_service -m net.zoidplex.wlr_gamma_service.brightness.set {}", temperature, brightness))
					.output()
					.unwrap();
		}
	}
}
