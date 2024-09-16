use color_eyre::eyre::{bail, Result};
use eyre::ensure;

pub static WHITESPACE: [char; 3] = [' ', '\n', '\t'];

#[derive(Debug, Clone, PartialEq, Eq)]
pub enum Token {
	Literal(String),
	LCurly,
	RCurly,
	LBrack,
	RBrack,
	LParan,
	RParan,
	InnerDelim,
	OuterDelim,
}

pub fn str_into_tokens(input: String) -> Result<Vec<Token>> {
	let mut tokens = Vec::new();
	let mut iter_chars = input.chars().peekable();

	let mut ongoing_literal = String::new();
	let mut double_quote_open = false;
	let mut last_is_escape = false;
	while let Some(c) = iter_chars.next() {
		if c == '\\' {
			last_is_escape = true;
			continue;
		}
		let escaped = match last_is_escape {
			true => {
				if !double_quote_open {
					bail!("Escape character outside of string literal");
				}
				last_is_escape = false;
				true
			}
			false => false,
		};

		if c == '"' && !escaped {
			double_quote_open = !double_quote_open;
			match double_quote_open {
				true => {
					ensure!(ongoing_literal.is_empty(), "Encountered literal with \" that does not start with it.");
				}
				false => {
					ongoing_literal.push(c);
					continue;
				}
			}
		}
		if double_quote_open {
			ongoing_literal.push(c);
			continue; // the opening and closing quotes will be appended as part of `_` match arm later.
		}

		let mut flush_literal_then_push = |t: Token| {
			if !ongoing_literal.is_empty() {
				tokens.push(Token::Literal(std::mem::take(&mut ongoing_literal)));
			}
			tokens.push(t);
		};

		match c {
			c if WHITESPACE.contains(&c) => {
				continue;
			}
			'{' => flush_literal_then_push(Token::LCurly),
			'}' => flush_literal_then_push(Token::RCurly),
			'[' => flush_literal_then_push(Token::LBrack),
			']' => flush_literal_then_push(Token::RBrack),
			'(' => flush_literal_then_push(Token::LParan),
			')' => flush_literal_then_push(Token::RParan),
			':' =>
				if iter_chars.next_if(|&x| WHITESPACE.contains(&x)).is_some() {
					flush_literal_then_push(Token::InnerDelim);
				},
			',' =>
				if iter_chars.next_if(|&x| WHITESPACE.contains(&x)).is_some() {
					flush_literal_then_push(Token::OuterDelim);
				},
			_ => {
				ongoing_literal.push(c);
			}
		}
	}

	if !ongoing_literal.is_empty() {
		// suspicious if ever reached
		tokens.push(Token::Literal(ongoing_literal));
	}

	Ok(tokens)
}

#[cfg(test)]
mod tests {
	use super::*;
	use crate::utils::INIT;

	#[test]
	fn reproduce_1() -> Result<()> {
		*INIT;
		let input = r#""dm", ordinal: 0 }"#;
		let tokens = str_into_tokens(input.to_owned())?;
		insta::assert_debug_snapshot!(tokens, @r###"
  [
      Literal(
          "\"dm\"",
      ),
      OuterDelim,
      Literal(
          "ordinal",
      ),
      InnerDelim,
      Literal(
          "0",
      ),
      RCurly,
  ]
  "###);
		Ok(())
	}

	#[test]
	fn parse_quotes_literally() -> Result<()> {
		*INIT;
		let input = r#"key: "What {value}, [one, two [named {value: map} ]]""#;
		let tokens = str_into_tokens(input.to_owned())?;
		insta::assert_debug_snapshot!(tokens, @r###"
  [
      Literal(
          "key",
      ),
      InnerDelim,
      Literal(
          "\"What {value}, [one, two [named {value: map} ]]\"",
      ),
  ]
  "###);
		Ok(())
	}
}
