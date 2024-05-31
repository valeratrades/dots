use clap::{ArgGroup, Args, Parser, Subcommand};

#[derive(Parser)]
#[command(author, version, about, long_about = None)]
struct Cli {
	#[command(subcommand)]
	command: Commands,
}
#[derive(Subcommand)]
enum Commands {
	/// Start the thing
	///Ex
	///```sh
	///PROJECT_NAME_PLACEHOLDER start -w "!"
	///```
	Start(StartArgs),
}

#[derive(Args)]
#[command(group(
    ArgGroup::new("channel")
        .required(true)
        .args(&["world", "rust"]),
))]
struct StartArgs {
	/// Hello to world
	#[arg(short, long)]
	world: bool,
	/// Hello to rust
	#[arg(short, long)]
	rust: bool,

	/// Message to send after hello
	after_hello_message: Vec<String>,
}

fn main() {
	let cli = Cli::parse();
	match cli.command {
		Commands::Start(args) => {
			let hello_target = match (args.world, args.rust) {
				(true, false) => "World",
				(false, true) => "Rust",
				(true, true) => panic!("Cannot hello two things"),
				(false, false) => panic!("Specify what to hello"),
			};

			let message = format!("Hello, {hello_target}{}", &args.after_hello_message.join(""));
			println!("{message}");
		}
	}
}
