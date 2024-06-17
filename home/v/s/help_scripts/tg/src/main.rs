use clap::{ArgGroup, Args, Parser, Subcommand};
use reqwest::Error;
use std::env;
use v_utils::io::ExpandedPath;
mod config;

#[derive(Parser)]
#[command(author, version, about, long_about = None)]
struct Cli {
	#[command(subcommand)]
	command: Commands,
	#[arg(long, default_value = "~/.config/tg.toml")]
	config: ExpandedPath,
}
#[derive(Subcommand)]
enum Commands {
	/// Send the message (if more than one string is provided, they are contatenated with a space)
	///Ex
	///```sh
	///tg send -j "today I'm feeling blue" "//this is still a part of the message"
	///```
	Send(SendArgs),
	/// Get information about the bot
	BotInfo,
}
#[derive(Args)]
#[command(group(
    ArgGroup::new("channel")
        .required(true)
        .args(&["wtt", "journal", "alerts"]),
))]
struct SendArgs {
	/// Send message to WTT channel
	#[arg(short, long)]
	wtt: bool,
	/// Send message to Journal channel
	#[arg(short, long)]
	journal: bool,
	/// Send message to Alerts channel
	#[arg(short, long)]
	alerts: bool,

	/// Message to send
	message: Vec<String>,
}

#[tokio::main]
async fn main() -> Result<(), Error> {
	let cli = Cli::parse();
	let config = config::AppConfig::read(cli.config).expect("Failed to read config file");
	//TODO!: make it possible to define the bot_token inside the config too (env overwrites if exists)
	let bot_token = env::var("TELEGRAM_BOT_KEY").expect("TELEGRAM_BOT_KEY not set");

	match cli.command {
		Commands::Send(args) => {
			let chat_id: isize;
			if args.wtt {
				chat_id = config.channels.wtt; //"-1001179171854";
			} else if args.journal {
				chat_id = config.channels.journal; //"-1002128875937";
			} else if args.alerts {
				chat_id = config.channels.alerts; //"-1001800341082";
			} else {
				unreachable!(); // ArgGroup should prevent this
			}

			let url = format!("https://api.telegram.org/bot{}/sendMessage", bot_token);
			let params = [("chat_id", format!("{chat_id}")), ("text", args.message.join(" "))];
			let client = reqwest::Client::new();
			let res = client.post(&url).form(&params).send().await?;

			println!("{:#?}\nTarget: {chat_id}; Sender: {bot_token}", res.text().await?);
		}
		Commands::BotInfo => {
			let url = format!("https://api.telegram.org/bot{}/getMe", bot_token);
			let client = reqwest::Client::new();
			let res = client.get(&url).send().await?;

			let parsed_json: serde_json::Value = serde_json::from_str(&res.text().await?).expect("Failed to parse JSON");
			let pretty_json = serde_json::to_string_pretty(&parsed_json).expect("Failed to pretty print JSON");
			println!("{}", pretty_json);
		}
	};

	Ok(())
}
