#![feature(stmt_expr_attributes)]
use ast::tokens_to_ast;
use clap::{command, Parser};
use clap_stdin::MaybeStdin;
use lexer::str_to_tokens;

mod ast;
mod lexer;

#[derive(Debug, Parser)]
#[command(author, version, about, long_about = None)]
struct Cli {
	s: MaybeStdin<String>,
}

fn main() {
	let args = Cli::parse();
	let input = format!("{}", args.s);

	let tokens = str_to_tokens(input);
	let parsed = tokens_to_ast(tokens);
	//println!("{parsed}");
}
