use std::fmt;

pub trait Pretty {
	/// Produce pretty Display of itself. `root_indent` is used when print contains newlines.
	fn pretty(&self, f: &mut std::fmt::Formatter<'_>, root_indent: u8) -> std::fmt::Result;
}

#[derive(Clone, Debug, PartialEq, Eq)]
pub enum TreeKind {
	Array(Vec<Value>),
	VecKvp(Vec<KeyValuePair>),
	NamedMap(NamedMap),
	NamedParams(NamedParams),
	Literal(Literal),
}

#[derive(Clone, Debug, Default, derive_new::new, PartialEq, Eq)]
pub struct NamedMap {
	name: Literal,
	contents: Vec<KeyValuePair>,
}

#[derive(Clone, Debug, Default, derive_new::new, PartialEq, Eq)]
pub struct NamedParams {
	name: Literal,
	contents: Vec<Value>,
}

#[derive(Clone, Debug, derive_new::new, PartialEq, Eq)]
pub enum Value {
	Array(Vec<Value>),
	Literal(Literal),
	NamedMap(NamedMap),
	NamedParams(NamedParams),
}

#[derive(Clone, Debug, derive_new::new, PartialEq, Eq)]
pub enum KeyValuePair {
	Standard { key: Literal, value: Box<Value> },
	RestPattern,
}

#[derive(Clone, Debug, Default, derive_new::new, PartialEq, Eq)]
pub struct Literal(pub String);
impl std::fmt::Display for Literal {
	fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
		write!(f, "{}", self.0)
	}
}

impl Pretty for TreeKind {
	fn pretty(&self, f: &mut fmt::Formatter<'_>, root_indent: u8) -> fmt::Result {
		match self {
			TreeKind::Array(arr) => arr.pretty(f, root_indent),
			TreeKind::VecKvp(vec_kvp) => vec_kvp.pretty(f, root_indent),
			TreeKind::NamedMap(named_map) => named_map.pretty(f, root_indent),
			TreeKind::NamedParams(named_params) => named_params.pretty(f, root_indent),
			TreeKind::Literal(literal) => literal.pretty(f, root_indent),
		}
	}
}

impl fmt::Display for TreeKind {
	fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
		self.pretty(f, 0)
	}
}

impl Pretty for Vec<Value> {
	fn pretty(&self, f: &mut fmt::Formatter<'_>, root_indent: u8) -> fmt::Result {
		if self.is_empty() {
			return write!(f, "[]");
		}

		writeln!(f, "[")?;
		for (i, value) in self.iter().enumerate() {
			write!(f, "{:indent$}", "", indent = (root_indent + 2) as usize)?;
			value.pretty(f, root_indent + 2)?;
			if i < self.len() - 1 {
				writeln!(f, ",")?;
			} else {
				writeln!(f)?;
			}
		}
		write!(f, "{:indent$}]", "", indent = root_indent as usize)
	}
}

impl Pretty for Vec<KeyValuePair> {
	fn pretty(&self, f: &mut fmt::Formatter<'_>, root_indent: u8) -> fmt::Result {
		if self.is_empty() {
			return write!(f, "{{}}");
		}

		for (i, kvp) in self.iter().enumerate() {
			write!(f, "{:indent$}", "", indent = (root_indent + 2) as usize)?;
			kvp.pretty(f, root_indent + 2)?;
			if i < self.len() - 1 {
				writeln!(f, ",")?;
			}
		}
		write!(f, "{:indent$}", "", indent = root_indent as usize)
	}
}

impl Pretty for NamedMap {
	fn pretty(&self, f: &mut fmt::Formatter<'_>, root_indent: u8) -> fmt::Result {
		writeln!(f, "{}{{", self.name)?;
		self.contents.pretty(f, root_indent)?;
		writeln!(f)?;
		write!(f, "{:indent$}}}", "", indent = root_indent as usize)
	}
}

impl Pretty for NamedParams {
	fn pretty(&self, f: &mut fmt::Formatter<'_>, root_indent: u8) -> fmt::Result {
		write!(f, "{}(", self.name)?;
		if self.contents.is_empty() {
			write!(f, ")")
		} else {
			for (i, value) in self.contents.iter().enumerate() {
				value.pretty(f, root_indent)?;
				if i < self.contents.len() - 1 {
					write!(f, ", ")?;
				}
			}
			write!(f, ")")
		}
	}
}

impl Pretty for Value {
	fn pretty(&self, f: &mut fmt::Formatter<'_>, root_indent: u8) -> fmt::Result {
		match self {
			Value::Array(arr) => arr.pretty(f, root_indent),
			Value::Literal(literal) => literal.pretty(f, root_indent),
			Value::NamedMap(named_map) => named_map.pretty(f, root_indent),
			Value::NamedParams(named_params) => named_params.pretty(f, root_indent),
		}
	}
}

impl Pretty for KeyValuePair {
	fn pretty(&self, f: &mut fmt::Formatter<'_>, root_indent: u8) -> fmt::Result {
		match self {
			KeyValuePair::Standard { key, value } => {
				write!(f, "\"{}\": ", key.0)?;
				value.pretty(f, root_indent)
			}
			KeyValuePair::RestPattern => write!(f, "..."),
		}
	}
}

impl Pretty for Literal {
	fn pretty(&self, f: &mut fmt::Formatter<'_>, _root_indent: u8) -> fmt::Result {
		write!(f, "{}", self.0)
	}
}

#[cfg(test)]
mod tests {
	use color_eyre::Result;

	
	use crate::{ast::tokens_into_ast, lexer::str_into_tokens, utils::INIT};

	#[test]
	fn simple_vec_kvp() -> Result<()> {
		*INIT;
		let input = r#"key: value"#;
		let tokens = str_into_tokens(input.to_owned())?;
		let ast = tokens_into_ast(tokens)?;
		insta::assert_snapshot!(ast, @r###"  "key": value"###);
		Ok(())
	}

	#[test]
	fn named_map() -> Result<()> {
		*INIT;
		let input = r#"Config{ name: "question", answer: 42 }"#;
		let tokens = str_into_tokens(input.to_owned())?;
		let ast = tokens_into_ast(tokens)?;
		insta::assert_snapshot!(ast, @r###"
  Config{
    "name": "question",
    "answer": 42
  }
  "###);
		Ok(())
	}

	#[test]
	fn named_params() -> Result<()> {
		*INIT;
		let input = r#"Function(arg1, arg2, "string arg")"#;
		let tokens = str_into_tokens(input.to_owned())?;
		dbg!(&tokens);
		let ast = tokens_into_ast(tokens)?;
		insta::assert_snapshot!(ast, @r###"Function(arg1, arg2, "string arg")"###);
		Ok(())
	}

	#[test]
	fn from_pretty() -> Result<()> {
		*INIT;
		let input = r#"
				MyMap {
						array: [1, 2, 3],
						nested: Name {
								a: "value",
								b: NestedFunction(1, 2, 3)
						},
						name: test,
						..
				}"#;
		let tokens = str_into_tokens(input.to_owned())?;
		let ast = tokens_into_ast(tokens)?;
		insta::assert_snapshot!(ast, @r###"
  MyMap{
    "array": [
      1,
      2,
      3
    ],
    "nested": Name{
      "a": "value",
      "b": NestedFunction(1, 2, 3)  
    },
    "name": test,
    ...
  }
  "###);
		Ok(())
	}

	#[test]
	fn log() -> Result<()> {
		let input = r#"hub_rx: Receiver { shared: Shared { value: RwLock(PhantomData<std::sync::rwlock::RwLock<discretionary_engine::exchange_apis::hub::HubToExchange>>, RwLock { data: HubToExchange { key: 0191cc99-b03a-7003-ab4d-ef05bef629ad, orders: [Order { id: PositionOrderId { position_id: 0191cc99-b039-7960-96d5-3230a8a0a12a, protocol_id: "dm", ordinal: 0 }, order_type: Market, symbol: Symbol { base: "ADA", quote: "USDT", market: BinanceFutures }, side: Buy, qty_notional: 30.78817733990148 }, None] } }), version: Version(2), is_closed: false, ref_count_rx: 1 }, version: Version(2) }, last_reported_fill_key: 00000000-0000-0000-0000-000000000000, currently_deployed: RwLock { data: [], poisoned: false, .. }"#;
		let tokens = str_into_tokens(input.to_owned())?;
		let ast = tokens_into_ast(tokens)?;
		let dont_cut_my_newlines_insta = format!("_\n{ast}\n_");

		insta::assert_snapshot!(dont_cut_my_newlines_insta, @r###"
  _
    "hub_rx": Receiver{
      "shared": Shared{
        "value": RwLock(PhantomData<stdsyncrwlockRwLock<discretionary_engineexchange_apishubHubToExchange>>, RwLock{
          "data": HubToExchange{
            "key": 0191cc99-b03a-7003-ab4d-ef05bef629ad,
            "orders": [
              Order{
                "id": PositionOrderId{
                  "position_id": 0191cc99-b039-7960-96d5-3230a8a0a12a,
                  "protocol_id": "dm",
                  "ordinal": 0              
                },
                "order_type": Market,
                "symbol": Symbol{
                  "base": "ADA",
                  "quote": "USDT",
                  "market": BinanceFutures              
                },
                "side": Buy,
                "qty_notional": 30.78817733990148            
              },
              None
            ]        
          }      
        }),
        "version": Version(2),
        "is_closed": false,
        "ref_count_rx": 1    
      },
      "version": Version(2)  
    },
    "last_reported_fill_key": 00000000-0000-0000-0000-000000000000,
    "currently_deployed": RwLock{
      "data": [],
      "poisoned": false,
      ...  
    }
  _
  "###);
		Ok(())
	}
}
