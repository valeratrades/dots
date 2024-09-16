#![feature(stmt_expr_attributes)]
#![allow(internal_features)] // what is the point of this flag? The only way to use internal_features right now is to explicitly opt-in
#![feature(fmt_internals)]
#![feature(let_chains)]
use ast::tokens_into_ast;
use clap::{command, Parser};
use clap_stdin::MaybeStdin;
use lexer::str_into_tokens;

mod ast;
mod lexer;
pub mod tree_kinds;
pub mod utils;

#[derive(Debug, Parser)]
#[command(author, version, about, long_about = None)]
struct Cli {
	s: MaybeStdin<String>,
}

fn main() {
	color_eyre::install().unwrap();
	let args = Cli::parse();
	let input = format!("{}", args.s);

	let tokens = str_into_tokens(input).unwrap();
	let parsed = tokens_into_ast(tokens).unwrap();
	println!("{parsed}");
}
