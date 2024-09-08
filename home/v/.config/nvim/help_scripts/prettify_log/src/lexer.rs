#[derive(Debug, Clone, PartialEq, Eq)]
pub enum Token {
	Literal(String),
	LCurly,
	RCurly,
	LBrack,
	RBrack,
	InnerDelimiter,
	OuterDelimiter,
}

pub fn str_to_tokens(input: String) -> Vec<Token> {
	let mut tokens = Vec::new();
	let mut iter_chars = input.chars().peekable();

	let mut ongoing_literal = String::new();
	let mut double_quote_open = false;
	while let Some(c) = iter_chars.next() {
		match double_quote_open {
			true => {
				ongoing_literal.push(c);
				if c == '"' {
					double_quote_open = false;
					tokens.push(Token::Literal(std::mem::take(&mut ongoing_literal)));
				}
			}
			false => {
				match c {
					' ' => continue,
					'{' => tokens.push(Token::LCurly),
					'}' => tokens.push(Token::RCurly),
					'[' => tokens.push(Token::LBrack),
					']' => tokens.push(Token::RBrack),
					// add next literal or consume primitive
					_ => {
						match c {
							':' => {
								if iter_chars.peek() == Some(&' ') {
									tokens.push(Token::Literal(std::mem::take(&mut ongoing_literal)));
									iter_chars.next(); // consume peeked
									tokens.push(Token::InnerDelimiter);
								}
							}
							',' => {
								if iter_chars.peek() == Some(&' ') {
									tokens.push(Token::Literal(std::mem::take(&mut ongoing_literal)));
									iter_chars.next(); // consume peeked
									tokens.push(Token::OuterDelimiter);
								}
							}
							_ => {
								if c == '"' {
									double_quote_open = true;
								}
								ongoing_literal.push(c);
							}
						}
					}
				}
			}
		}
	}

	if !ongoing_literal.is_empty() {
		tokens.push(Token::Literal(ongoing_literal));
	}

	tokens
}
