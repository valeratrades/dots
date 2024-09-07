use crate::lexer::Token;

#[derive(Clone, Debug, Default, derive_new::new)]
pub struct Ast(Vec<KeyValuePair>);
impl std::fmt::Display for Ast {
	fn fmt(&self, f: &mut std::fmt::Formatter) -> std::fmt::Result {
		for (i, pair) in self.0.iter().enumerate() {
			write!(f, "{}", pair)?;
			if i < self.0.len() - 1 {
				write!(f, "\n\n")?;
			}
		}
		Ok(())
	}
}

#[derive(Clone, Debug, Default, derive_new::new)]
struct KeyValuePair {
	key: String,
	value: Ast,
}
impl std::fmt::Display for KeyValuePair {
	fn fmt(&self, f: &mut std::fmt::Formatter) -> std::fmt::Result {
		write!(f, "{}: {}", self.key, self.value)
	}
}

// Array: [ Ast, * ]
// KeyValuePair: Literal: Ast
// Map: Literal { KeyValuePair, * }
// Literal

pub fn tokens_to_ast(tokens: Vec<Token>) -> Ast {
	Ast::default()
}

#[cfg(test)]
mod tests {
	use super::*;
	use crate::lexer::str_to_tokens;

	#[test]
	fn simple() {
		let input = r#"key: value"#;
		let tokens = str_to_tokens(input.to_owned());
		let ast = tokens_to_ast(tokens);
		insta::assert_debug_snapshot!(ast, @r###"
  Ast(
      [],
  )
  "###);
	}

	#[test]
	fn log() {
		let input = r#"hub_rx: Receiver { shared: Shared { value: RwLock(PhantomData<std::sync::rwlock::RwLock<discretionary_engine::exchange_apis::hub::HubToExchange>>, RwLock { data: HubToExchange { key: 0191cc99-b03a-7003-ab4d-ef05bef629ad, orders: [Order { id: PositionOrderId { position_id: 0191cc99-b039-7960-96d5-3230a8a0a12a, protocol_id: "dm", ordinal: 0 }, order_type: Market, symbol: Symbol { base: "ADA", quote: "USDT", market: BinanceFutures }, side: Buy, qty_notional: 30.78817733990148 }, None] } }), version: Version(2), is_closed: false, ref_count_rx: 1 }, version: Version(2) }, last_reported_fill_key: 00000000-0000-0000-0000-000000000000, currently_deployed: RwLock { data: [], poisoned: false, .. }"#;
		let tokens = str_to_tokens(input.to_owned());
		let ast = tokens_to_ast(tokens);
		insta::assert_debug_snapshot!(ast, @r###"
  Ast(
      [],
  )
  "###);
	}
}
