use clap::{ArgGroup, Args, Parser, Subcommand};
use reqwest::Error;
use std::env;

#[derive(Parser)]
#[command(author, version, about, long_about = None)]
struct Cli {
	#[command(subcommand)]
	command: Commands,
}
#[derive(Subcommand)]
enum Commands {
	/// Send the message (if more than one string is provided, they are contatenated with a space)
	///Ex
	///```sh
	///tg send -j "today I'm feeling blue" "//this is still a part of the message"
	///```
	Send(SendArgs),
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
	let bot_token = env::var("TELEGRAM_BOT_KEY").expect("TELEGRAM_BOT_KEY not set");

	match cli.command {
		Commands::Send(args) => {
			let chat_id: &'static str;
			if args.wtt {
				chat_id = "-1001179171854";
			} else if args.journal {
				chat_id = "-1002128875937";
			} else if args.alerts {
				chat_id = "-1001800341082";
			} else {
				unreachable!(); // ArgGroup should prevent this
			}

			let url = format!("https://api.telegram.org/bot{}/sendMessage", bot_token);
			let params = [("chat_id", chat_id), ("text", &args.message.join(" "))];
			let client = reqwest::Client::new();
			let res = client.post(&url).form(&params).send().await?;

			println!("{:#?}", res.text().await?);
		}
	};

	Ok(())
}
