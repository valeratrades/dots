#[allow(unused_variables)]
use chrono::prelude::*;
use std::{
	ffi::OsStr,
	process::{Command, Output},
};

#[derive(Debug)]
struct Waketime {
	hours: u32,
	minutes: u32,
}
impl From<String> for Waketime {
	fn from(s: String) -> Self {
		let split: Vec<_> = s.split(':').collect();
		assert!(split.len() == 2, "ERROR: waketime should be supplied in the format: \"%H:%M\"");
		let hours: u32 = split[0].parse().unwrap();
		let minutes: u32 = split[1].parse().unwrap();
		Waketime { hours, minutes }
	}
}

fn main() {
	let args: Vec<String> = std::env::args().collect();
	assert!(args.len() == 2, "ERROR: provide one and only one argument, being the bedtime in format: '%H:%M'");
	let waketime: Waketime = args[1].clone().into();

	// dancing with tambourine to get into the 30m cycle
	// god forgive me
	let good_minutes_small = (waketime.minutes + 1) % 30; // +1 is offset of the cycle by 1m, to prevent bugs from having undecisive behavior on definition borders
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
	set_redshift(&waketime);
	std::thread::sleep(std::time::Duration::from_secs(_wait_to_sync_m as u64 * 60));
	loop {
		set_redshift(&waketime);
		std::thread::sleep(std::time::Duration::from_secs(30 * 60));
	}
}

fn set_redshift(waketime: &Waketime) {
	let nm = Utc::now().hour() * 60 + Utc::now().minute();
	let wt = waketime.hours * 60 + waketime.minutes;

	// shift everything wt minutes back
	// in python would be `(nm - wt) % 24`, but rust doesn't want to exhibit desired behaviour with % on negative numbers
	let mut now_shifted = nm as i32 - wt as i32;
	if now_shifted < 0 {
		now_shifted += 24 * 60;
	}

	// I guess I could be taking the day section borders as args
	let day_section: String = match now_shifted {
		t if (t > 20 * 60) || (t <= 150) => "morning".to_owned(),
		t if t <= 150 + 8 * 60 => "day".to_owned(),
		t if t <= 16 * 60 => "evening".to_owned(),
		_ => "night".to_owned(),
	};

	// by default we have brightness=1 and temperature=6500. With every level we decrease them by 0.0275 and 210 accordingly. Max redshift is level 20, where we arrive at 0.45 and 2300 accordingly.
	let redshift: u32;
	// wallpapers are in ~/Wallpapers
	let wallpaper: &str;

	match day_section.as_str() {
		"morning" => {
			redshift = 0;
			wallpaper = "1929.jpg";
		}
		"day" => {
			redshift = 0;
			wallpaper = "AndreySakharov.jpg";
		}
		"evening" => {
			if now_shifted > 12 * 60 {
				redshift = ((now_shifted as f32 / 60.0 - 12.0 + 0.5) * 5.0) as u32;
			} else {
				redshift = 0;
			}
			wallpaper = "girl_with_a_perl_earring.jpg";
		}
		"night" => {
			redshift = 20;
			wallpaper = "girl_with_a_perl_earring.jpg";
		}
		_ => unreachable!(),
	}

	if redshift != 0 {
		let temperature: f32 = 6500.0 - redshift as f32 * 210.0;
		let brightness: f32 = 1.0 - redshift as f32 * 0.0275;

		let extra_characters: &[_] = &['(', ')', ','];
		let current_temperature_output =
			cmd("gdbus call -e -d net.zoidplex.wlr_gamma_service -o /net/zoidplex/wlr_gamma_service -m net.zoidplex.wlr_gamma_service.temperature.get".to_owned());
		let current_temperature = String::from_utf8_lossy(&current_temperature_output.stdout)
			.trim()
			.to_string()
			.trim_matches(extra_characters)
			.parse()
			.unwrap();
		let current_brightness_output = cmd("gdbus call -e -d net.zoidplex.wlr_gamma_service -o /net/zoidplex/wlr_gamma_service -m net.zoidplex.wlr_gamma_service.brightness.get".to_owned());
		let current_brightness = String::from_utf8_lossy(&current_brightness_output.stdout)
			.trim()
			.to_string()
			.trim_matches(extra_characters)
			.parse()
			.unwrap();

		// // Set things
		if temperature < current_temperature && brightness < current_brightness {
			let _ = cmd(format!("gdbus call -e -d net.zoidplex.wlr_gamma_service -o /net/zoidplex/wlr_gamma_service -m net.zoidplex.wlr_gamma_service.temperature.set {} && gdbus call -e -d net.zoidplex.wlr_gamma_service -o /net/zoidplex/wlr_gamma_service -m net.zoidplex.wlr_gamma_service.brightness.set {}", temperature, brightness));
		}

		let _ = cmd(format!("swaymsg output '*' bg ~/Wallpapers/{} fill", wallpaper));
		//
	}
}

fn cmd<S>(command: S) -> Output
where
	S: AsRef<OsStr>,
{
	let output = Command::new("sh").arg("-c").arg(command).output().unwrap();
	output
}
