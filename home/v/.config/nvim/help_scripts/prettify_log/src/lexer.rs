#[derive(Debug, Clone, PartialEq, Eq)]
pub enum Token {
	Literal(String),
	OpeningCurlyBracket,
	ClosingCurlyBracket,
	OpeningSquareBracket,
	ClosingSquareBracket,
	InnerDelimiter,
	OuterDelimiter,
}

pub fn str_to_tokens(input: String) -> Vec<Token> {
	let mut tokens = Vec::new();
	let mut iter_chars = input.chars().peekable();

	let mut ongoing_literal = String::new();
	while let Some(c) = iter_chars.next() {
		match c {
			' ' => continue,
			'{' => tokens.push(Token::OpeningCurlyBracket),
			'}' => tokens.push(Token::ClosingCurlyBracket),
			'[' => tokens.push(Token::OpeningSquareBracket),
			']' => tokens.push(Token::ClosingSquareBracket),
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
					_ => ongoing_literal.push(c),
				}
			}
		}
	}
	if !ongoing_literal.is_empty() {
		tokens.push(Token::Literal(ongoing_literal));
	}

	tokens
}

#[cfg(test)]
mod tests {
	use super::*;

	#[test]
	fn simple() {
		let input = r#"key: value"#;
		insta::assert_debug_snapshot!(str_to_tokens(input.to_owned()), @r###"
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
	}

	#[test]
	fn log() {
		let input = r#"hub_rx: Receiver { shared: Shared { value: RwLock(PhantomData<std::sync::rwlock::RwLock<discretionary_engine::exchange_apis::hub::HubToExchange>>, RwLock { data: HubToExchange { key: 0191cc99-b03a-7003-ab4d-ef05bef629ad, orders: [Order { id: PositionOrderId { position_id: 0191cc99-b039-7960-96d5-3230a8a0a12a, protocol_id: "dm", ordinal: 0 }, order_type: Market, symbol: Symbol { base: "ADA", quote: "USDT", market: BinanceFutures }, side: Buy, qty_notional: 30.78817733990148 }, None] } }), version: Version(2), is_closed: false, ref_count_rx: 1 }, version: Version(2) }, last_reported_fill_key: 00000000-0000-0000-0000-000000000000, currently_deployed: RwLock { data: [], poisoned: false, .. }"#;
		insta::assert_debug_snapshot!(str_to_tokens(input.to_owned()), @r###"
  [
      Literal(
          "hub_rx",
      ),
      InnerDelimiter,
      OpeningCurlyBracket,
      Literal(
          "Receivershared",
      ),
      InnerDelimiter,
      OpeningCurlyBracket,
      Literal(
          "Sharedvalue",
      ),
      InnerDelimiter,
      Literal(
          "RwLock(PhantomData<stdsyncrwlockRwLock<discretionary_engineexchange_apishubHubToExchange>>",
      ),
      OuterDelimiter,
      OpeningCurlyBracket,
      Literal(
          "RwLockdata",
      ),
      InnerDelimiter,
      OpeningCurlyBracket,
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
      OpeningSquareBracket,
      OpeningCurlyBracket,
      Literal(
          "Orderid",
      ),
      InnerDelimiter,
      OpeningCurlyBracket,
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
      OuterDelimiter,
      Literal(
          "ordinal",
      ),
      InnerDelimiter,
      ClosingCurlyBracket,
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
      OpeningCurlyBracket,
      Literal(
          "Symbolbase",
      ),
      InnerDelimiter,
      Literal(
          "\"ADA\"",
      ),
      OuterDelimiter,
      Literal(
          "quote",
      ),
      InnerDelimiter,
      Literal(
          "\"USDT\"",
      ),
      OuterDelimiter,
      Literal(
          "market",
      ),
      InnerDelimiter,
      ClosingCurlyBracket,
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
      ClosingCurlyBracket,
      Literal(
          "30.78817733990148",
      ),
      OuterDelimiter,
      ClosingSquareBracket,
      ClosingCurlyBracket,
      ClosingCurlyBracket,
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
      ClosingCurlyBracket,
      Literal(
          "1",
      ),
      OuterDelimiter,
      Literal(
          "version",
      ),
      InnerDelimiter,
      ClosingCurlyBracket,
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
      OpeningCurlyBracket,
      Literal(
          "RwLockdata",
      ),
      InnerDelimiter,
      OpeningSquareBracket,
      ClosingSquareBracket,
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
      ClosingCurlyBracket,
      Literal(
          "..",
      ),
  ]
  "###);
	}
}
