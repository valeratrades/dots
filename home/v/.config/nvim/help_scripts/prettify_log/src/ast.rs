use std::collections::BTreeMap;

use crate::lexer::Token;

#[derive(Clone, Debug)]
pub enum TreeKind {
	Array(Vec<TreeKind>), // Map | Literal
	KeyValuePairs(Vec<KeyValuePair>),
	Map { name: Literal, contents: Vec<KeyValuePair> },
	Literal(Literal),
}

#[derive(Clone, Debug, derive_new::new)]
pub struct KeyValuePair {
	key: Literal,
	value: Box<TreeKind>, // Map | Array | Literal
}

impl std::fmt::Display for KeyValuePair {
	fn fmt(&self, f: &mut std::fmt::Formatter) -> std::fmt::Result {
		write!(f, "{}: {}", self.key, self.value)
	}
}

#[derive(Clone, Debug, Default, derive_new::new)]
pub struct Literal(String);

impl std::fmt::Display for Literal {
	fn fmt(&self, f: &mut std::fmt::Formatter) -> std::fmt::Result {
		write!(f, "{}", self.0)
	}
}

impl std::fmt::Display for TreeKind {
	fn fmt(&self, f: &mut std::fmt::Formatter) -> std::fmt::Result {
		match self {
			TreeKind::Array(array) => {
				let elements: Vec<String> = array.iter().map(|elem| format!("{}", elem)).collect();
				write!(f, "[{}]", elements.join(", "))
			}
			TreeKind::KeyValuePairs(kvps) => {
				let kvps: Vec<String> = kvps.iter().map(|kvp| format!("{}", kvp)).collect();
				write!(f, "{}", kvps.join(", "))
			}
			TreeKind::Map { name, contents } => {
				let kvps: Vec<String> = contents.iter().map(|kvp| format!("{}", kvp)).collect();
				write!(f, "{} {{ {} }}", name, kvps.join(", "))
			}
			TreeKind::Literal(literal) => write!(f, "{}", literal),
		}
	}
}

#[derive(Clone, Debug)]
enum MaybeParsed {
	Parsed(TreeKind),
	Curlies(Vec<MaybeParsed>),
	Bracks(Vec<MaybeParsed>),
	Raw(Token),
}

pub fn tokens_to_ast(tokens: Vec<Token>) -> TreeKind {
	let maybe_parsed: Vec<MaybeParsed> = tokens.into_iter().map(MaybeParsed::Raw).collect();
	let mut maybe_parsed_new = maybe_parsed.clone();

	let mut i = 0;
	while i < maybe_parsed_new.len() {
		match maybe_parsed_new[i] {
			MaybeParsed::Raw(Token::LCurly) => {
				let start_i = i;
				let mut open_curlies = 1;
				let mut inside_outer_curly_tokens = Vec::new();
				loop {
					i += 1;
					if i >= maybe_parsed_new.len() {
						panic!("unmatched curly. TODO: error token and tree kinds (ref https://matklad.github.io/2023/05/21/resilient-ll-parsing-tutorial.html)");
					}
					match maybe_parsed_new[i] {
						MaybeParsed::Raw(Token::LCurly) => {
							open_curlies += 1;
						}
						MaybeParsed::Raw(Token::RCurly) => {
							open_curlies -= 1;
							if open_curlies == 0 {
								break;
							}
						}
						_ => {}
					}
					inside_outer_curly_tokens.push(maybe_parsed_new[i].clone());
				}
				maybe_parsed_new.splice(start_i..=i, vec![MaybeParsed::Curlies(inside_outer_curly_tokens)]);
				#[allow(unused_assignments)] // the fuck, RA
				i = start_i;
				break;
			}
			_ => {
				//todo!();
			}
		}
		i += 1;
	}
	dbg!(&maybe_parsed_new);

	TreeKind::Array(vec![]) //dbg
}

// combined, so that I don't have to update token def, nor go to another file to see the expanded lexer output
#[cfg(test)]
mod tests {
	use super::*;
	use crate::lexer::str_to_tokens;

	#[test]
	fn simple() {
		let input = r#"key: value"#;
		let tokens = str_to_tokens(input.to_owned());
		insta::assert_debug_snapshot!(tokens, @r###"
  [
      Literal(
          "key",
      ),
      InnerDelimiter,
      Literal(
          "value",
      ),
  ]
  "###);

		let ast = tokens_to_ast(tokens);
		insta::assert_debug_snapshot!(ast, @r###"
  Array(
      [],

  )
  "###);
	}

	#[test]
	fn log() {
		let input = r#"hub_rx: Receiver { shared: Shared { value: RwLock(PhantomData<std::sync::rwlock::RwLock<discretionary_engine::exchange_apis::hub::HubToExchange>>, RwLock { data: HubToExchange { key: 0191cc99-b03a-7003-ab4d-ef05bef629ad, orders: [Order { id: PositionOrderId { position_id: 0191cc99-b039-7960-96d5-3230a8a0a12a, protocol_id: "dm", ordinal: 0 }, order_type: Market, symbol: Symbol { base: "ADA", quote: "USDT", market: BinanceFutures }, side: Buy, qty_notional: 30.78817733990148 }, None] } }), version: Version(2), is_closed: false, ref_count_rx: 1 }, version: Version(2) }, last_reported_fill_key: 00000000-0000-0000-0000-000000000000, currently_deployed: RwLock { data: [], poisoned: false, .. }"#;
		let tokens = str_to_tokens(input.to_owned());
		insta::assert_debug_snapshot!(tokens, @r###"
  [
      Literal(
          "hub_rx",
      ),
      InnerDelimiter,
      LCurly,
      Literal(
          "Receivershared",
      ),
      InnerDelimiter,
      LCurly,
      Literal(
          "Sharedvalue",
      ),
      InnerDelimiter,
      Literal(
          "RwLock(PhantomData<stdsyncrwlockRwLock<discretionary_engineexchange_apishubHubToExchange>>",
      ),
      OuterDelimiter,
      LCurly,
      Literal(
          "RwLockdata",
      ),
      InnerDelimiter,
      LCurly,
      Literal(
          "HubToExchangekey",
      ),
      InnerDelimiter,
      Literal(
          "0191cc99-b03a-7003-ab4d-ef05bef629ad",
      ),
      OuterDelimiter,
      Literal(
          "orders",
      ),
      InnerDelimiter,
      LBrack,
      LCurly,
      Literal(
          "Orderid",
      ),
      InnerDelimiter,
      LCurly,
      Literal(
          "PositionOrderIdposition_id",
      ),
      InnerDelimiter,
      Literal(
          "0191cc99-b039-7960-96d5-3230a8a0a12a",
      ),
      OuterDelimiter,
      Literal(
          "protocol_id",
      ),
      InnerDelimiter,
      Literal(
          "\"dm\"",
      ),
      Literal(
          "",
      ),
      OuterDelimiter,
      Literal(
          "ordinal",
      ),
      InnerDelimiter,
      RCurly,
      Literal(
          "0",
      ),
      OuterDelimiter,
      Literal(
          "order_type",
      ),
      InnerDelimiter,
      Literal(
          "Market",
      ),
      OuterDelimiter,
      Literal(
          "symbol",
      ),
      InnerDelimiter,
      LCurly,
      Literal(
          "Symbolbase",
      ),
      InnerDelimiter,
      Literal(
          "\"ADA\"",
      ),
      Literal(
          "",
      ),
      OuterDelimiter,
      Literal(
          "quote",
      ),
      InnerDelimiter,
      Literal(
          "\"USDT\"",
      ),
      Literal(
          "",
      ),
      OuterDelimiter,
      Literal(
          "market",
      ),
      InnerDelimiter,
      RCurly,
      Literal(
          "BinanceFutures",
      ),
      OuterDelimiter,
      Literal(
          "side",
      ),
      InnerDelimiter,
      Literal(
          "Buy",
      ),
      OuterDelimiter,
      Literal(
          "qty_notional",
      ),
      InnerDelimiter,
      RCurly,
      Literal(
          "30.78817733990148",
      ),
      OuterDelimiter,
      RBrack,
      RCurly,
      RCurly,
      Literal(
          "None)",
      ),
      OuterDelimiter,
      Literal(
          "version",
      ),
      InnerDelimiter,
      Literal(
          "Version(2)",
      ),
      OuterDelimiter,
      Literal(
          "is_closed",
      ),
      InnerDelimiter,
      Literal(
          "false",
      ),
      OuterDelimiter,
      Literal(
          "ref_count_rx",
      ),
      InnerDelimiter,
      RCurly,
      Literal(
          "1",
      ),
      OuterDelimiter,
      Literal(
          "version",
      ),
      InnerDelimiter,
      RCurly,
      Literal(
          "Version(2)",
      ),
      OuterDelimiter,
      Literal(
          "last_reported_fill_key",
      ),
      InnerDelimiter,
      Literal(
          "00000000-0000-0000-0000-000000000000",
      ),
      OuterDelimiter,
      Literal(
          "currently_deployed",
      ),
      InnerDelimiter,
      LCurly,
      Literal(
          "RwLockdata",
      ),
      InnerDelimiter,
      LBrack,
      RBrack,
      Literal(
          "",
      ),
      OuterDelimiter,
      Literal(
          "poisoned",
      ),
      InnerDelimiter,
      Literal(
          "false",
      ),
      OuterDelimiter,
      RCurly,
      Literal(
          "..",
      ),
  ]
  "###);

		let ast = tokens_to_ast(tokens);
		insta::assert_debug_snapshot!(ast, @r###"
  Array(
      [],

  )
  "###);
	}

	#[test]
	fn parse_quotes_literally() {
		let input = r#"key: "What {value}""#;
		let tokens = str_to_tokens(input.to_owned());
		insta::assert_debug_snapshot!(tokens, @r###"
  [
      Literal(
          "key",
      ),
      InnerDelimiter,
      Literal(
          "\"What {value}\"",
      ),
  ]
  "###);
		let ast = tokens_to_ast(tokens);
		insta::assert_debug_snapshot!(ast, @r###"
  Array(
      [],
			
  )
  "###);
	}
}
