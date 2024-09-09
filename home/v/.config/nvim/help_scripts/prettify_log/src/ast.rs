use color_eyre::eyre::{bail, ensure, Result};

use crate::{lexer::Token, tree_kinds::*};

#[derive(Clone, Debug, PartialEq, Eq)]
pub enum MaybeParsed {
	Curlies(Vec<KeyValuePair>),
	KeyValuePair(KeyValuePair),
	Bracks(Vec<Value>),
	Parens(Vec<Value>), // seems to be array-like, same as Bracks
	NamedMap(NamedMap),
	NamedParams(NamedParams),
	Raw(Token),
}

/// Captures the outer-most level of parens, and attempts to interpret their insides.
fn capture_parens(tokens: Vec<Token>) -> Result<Vec<MaybeParsed>> {
	let mut parens_or_raw = Vec::new();
	let mut iter_tokens = tokens.into_iter().peekable();
	while let Some(t) = iter_tokens.next() {
		match t {
			Token::LCurly | Token::LBrack | Token::LParan => {
				let mut open_parens = 1;
				let mut insides = Vec::new();
				let closing = match t {
					Token::LCurly => Token::RCurly,
					Token::LBrack => Token::RBrack,
					Token::LParan => Token::RParan,
					_ => unreachable!(),
				};
				let opening = t;

				for next in iter_tokens.by_ref() {
					if next == opening {
						open_parens += 1;
					} else if next == closing {
						open_parens -= 1;
					}

					match open_parens == 0 {
						true => {
							// current token is last closing paren, so we don't care to add it
							let preliminary_pass = preliminary_pass(insides)?;
							match opening {
								Token::LCurly => parens_or_raw.push(MaybeParsed::Curlies(try_assume_vec_kvp(preliminary_pass)?)),
								Token::LBrack => parens_or_raw.push(MaybeParsed::Bracks(try_assume_array(preliminary_pass)?)),
								Token::LParan => parens_or_raw.push(MaybeParsed::Parens(try_assume_array(preliminary_pass)?)),
								_ => unreachable!(),
							}
							break;
						}
						false => insides.push(next),
					}
				}
			}
			_ => parens_or_raw.push(MaybeParsed::Raw(t)),
		}
	}
	Ok(parens_or_raw)
}

/// Capture all [NamedMap]s
fn capture_maps_and_params(parens_or_raw: Vec<MaybeParsed>) -> Result<Vec<MaybeParsed>> {
	let mut oneof_raw_map_params_bracks = Vec::new();
	let mut iter_parens_or_raw = parens_or_raw.into_iter().peekable();
	// exclusively searching for `Literal, Curlies`
	while let Some(t) = iter_parens_or_raw.next() {
		match t {
			MaybeParsed::Raw(Token::Literal(literal)) => {
				match iter_parens_or_raw.peek() {
					Some(MaybeParsed::Curlies(_)) => {
						let contents = match iter_parens_or_raw.next().unwrap() {
							MaybeParsed::Curlies(contents) => contents,
							_ => unreachable!(),
						};
						let map = NamedMap::new(Literal(literal), contents.clone());
						oneof_raw_map_params_bracks.push(MaybeParsed::NamedMap(map));
					}
					Some(MaybeParsed::Parens(_)) => {
						let contents = match iter_parens_or_raw.next().unwrap() {
							MaybeParsed::Parens(contents) => contents,
							_ => unreachable!(),
						};
						let params = NamedParams::new(Literal(literal), contents);
						oneof_raw_map_params_bracks.push(MaybeParsed::NamedParams(params));
					}
					_ => oneof_raw_map_params_bracks.push(MaybeParsed::Raw(Token::Literal(literal))), // effectively `push(t)`
				}
			}
			_ => oneof_raw_map_params_bracks.push(t),
		}
	}
	Ok(oneof_raw_map_params_bracks)
}

/// Alias for [capture_maps_and_params] ( [capture_parens] (tokens))
fn preliminary_pass(tokens: Vec<Token>) -> Result<Vec<MaybeParsed>> {
	let parens_or_raw = capture_parens(tokens)?;
	let oneof_raw_map_params_bracks = capture_maps_and_params(parens_or_raw)?;
	Ok(oneof_raw_map_params_bracks)
}

/// Captures insides of Curlies
fn try_assume_vec_kvp(oneof_raw_map_params_bracks: Vec<MaybeParsed>) -> Result<Vec<KeyValuePair>> {
	let mut kvp_or_outer_delim = Vec::new();
	let mut iter_raw_map_or_bracks = oneof_raw_map_params_bracks.into_iter().peekable();
	// exclusively searching for `Literal, InnerDelimiter, Curlies | Bracks | Literal`
	while let Some(t) = iter_raw_map_or_bracks.next() {
		match t {
			MaybeParsed::Raw(Token::Literal(key)) => match iter_raw_map_or_bracks.peek() {
				Some(MaybeParsed::Raw(Token::InnerDelim)) => {
					iter_raw_map_or_bracks.next(); // consume the inner delimiter
					let value: Value = match iter_raw_map_or_bracks.next() {
						Some(MaybeParsed::NamedMap(map)) => Value::NamedMap(map),
						Some(MaybeParsed::Bracks(arr)) => Value::Array(arr),
						Some(MaybeParsed::NamedParams(params)) => Value::NamedParams(params),
						Some(MaybeParsed::Raw(Token::Literal(literal))) => Value::Literal(Literal(literal)),
						_ => bail!("Incorrect or missing KeyValuePair's Value"),
					};
					kvp_or_outer_delim.push(MaybeParsed::KeyValuePair(KeyValuePair::Standard {
						key: Literal(key),
						value: Box::new(value),
					}));
				}
				_ => match key.as_str() {
					".." => kvp_or_outer_delim.push(MaybeParsed::KeyValuePair(KeyValuePair::RestPattern)),
					_ => bail!("Encountered Token::Literal that is not part of a KeyValuePair"),
				},
			},
			MaybeParsed::Raw(Token::OuterDelim) => kvp_or_outer_delim.push(t),
			_ => {
				bail!("Encountered Token that is not part of a KeyValuePair");
			}
		}
	}

	let mut vec_kvp = Vec::new();
	let mut iter_kvp_or_outer_delim = kvp_or_outer_delim.into_iter();
	while let Some(t) = iter_kvp_or_outer_delim.next() {
		match t {
			MaybeParsed::KeyValuePair(kvp) => vec_kvp.push(kvp),
			MaybeParsed::Raw(Token::OuterDelim) => {
				let kvp_after = match iter_kvp_or_outer_delim.next() {
					Some(MaybeParsed::KeyValuePair(kvp)) => kvp,
					_ => bail!("OuterDelimiter must be followed by KeyValuePair"),
				};
				vec_kvp.push(kvp_after);
			}
			_ => bail!("Unmatched outer delim in vec of kvp"),
		}
	}
	Ok(vec_kvp)
}

/// Captures insides of Bracks
pub fn try_assume_array(oneof_raw_map_params_bracks: Vec<MaybeParsed>) -> Result<Vec<Value>> {
	if oneof_raw_map_params_bracks.len() == 0 {
		return Ok(Vec::new());
	}

	let mut array_of_values = Vec::new();
	for slice in oneof_raw_map_params_bracks.split(|item| *item == MaybeParsed::Raw(Token::OuterDelim)) {
		ensure!(slice.len() == 1);
		assert_eq!(slice.len(), 1);
		let value = match &slice[0] {
			MaybeParsed::Raw(Token::Literal(literal)) => Value::Literal(Literal(literal.clone())),
			MaybeParsed::Bracks(bracks) => Value::Array(bracks.clone()),
			MaybeParsed::NamedParams(params) => Value::NamedParams(params.clone()),
			MaybeParsed::NamedMap(map) => Value::NamedMap(map.clone()),
			_ => bail!("Array can only contain `Value` types"),
		};
		array_of_values.push(value);
	}
	Ok(array_of_values)
}

///PERF: calculation duplications, but who cares
pub fn tokens_into_ast(tokens: Vec<Token>) -> Result<TreeKind> {
	let parens_or_raw = capture_parens(tokens)?;
	let oneof_raw_map_params_bracks = capture_maps_and_params(parens_or_raw)?;
	//- [0] is NamedMap?
	//- [0] is NamedParams?
	//- [0] is Array?
	if let Ok(vec_kvp) = try_assume_vec_kvp(oneof_raw_map_params_bracks.clone()) {
		Ok(TreeKind::VecKvp(vec_kvp))
	} else if let MaybeParsed::NamedMap(map) = &oneof_raw_map_params_bracks[0]
		&& oneof_raw_map_params_bracks.len() == 1
	{
		return Ok(TreeKind::NamedMap(map.clone()));
	} else if let MaybeParsed::NamedParams(params) = &oneof_raw_map_params_bracks[0]
		&& oneof_raw_map_params_bracks.len() == 1
	{
		return Ok(TreeKind::NamedParams(params.clone()));
	} else {
		let error_msg = "Could not convert tokens to AST";
		if oneof_raw_map_params_bracks.len() == 1 {
			match &oneof_raw_map_params_bracks[0] {
				MaybeParsed::Raw(Token::Literal(literal)) => return Ok(TreeKind::Literal(Literal(literal.to_string()))),
				_ => bail!(error_msg),
			}
		}

		bail!(error_msg)
	}
}

// combined, so that I don't have to update token def, nor go to another file to see the expanded lexer output
#[cfg(test)]
mod tests {
	use super::*;
	use crate::{lexer::str_into_tokens, utils::INIT};

	#[test]
	fn simple_vec_kvp() -> Result<()> {
		*INIT;
		let input = r#"key: value"#;
		let tokens = str_into_tokens(input.to_owned())?;
		insta::assert_debug_snapshot!(tokens, @r###"
  [
      Literal(
          "key",
      ),
      InnerDelim,
      Literal(
          "value",
      ),
  ]
  "###);

		let vec_kvp = tokens_into_ast(tokens)?;
		insta::assert_debug_snapshot!(vec_kvp, @r###"
  VecKvp(
      [
          Standard {
              key: Literal(
                  "key",
              ),
              value: Literal(
                  Literal(
                      "value",
                  ),
              ),
          },
      ],
  )
  "###);
		Ok(())
	}

	#[test]
	fn log() -> Result<()> {
		*INIT;
		let input = r#"hub_rx: Receiver { shared: Shared { value: RwLock(PhantomData<std::sync::rwlock::RwLock<discretionary_engine::exchange_apis::hub::HubToExchange>>, RwLock { data: HubToExchange { key: 0191cc99-b03a-7003-ab4d-ef05bef629ad, orders: [Order { id: PositionOrderId { position_id: 0191cc99-b039-7960-96d5-3230a8a0a12a, protocol_id: "dm", ordinal: 0 }, order_type: Market, symbol: Symbol { base: "ADA", quote: "USDT", market: BinanceFutures }, side: Buy, qty_notional: 30.78817733990148 }, None] } }), version: Version(2), is_closed: false, ref_count_rx: 1 }, version: Version(2) }, last_reported_fill_key: 00000000-0000-0000-0000-000000000000, currently_deployed: RwLock { data: [], poisoned: false, .. }"#;
		let tokens = str_into_tokens(input.to_owned())?;
		insta::assert_debug_snapshot!(tokens, @r###"
  [
      Literal(
          "hub_rx",
      ),
      InnerDelim,
      Literal(
          "Receiver",
      ),
      LCurly,
      Literal(
          "shared",
      ),
      InnerDelim,
      Literal(
          "Shared",
      ),
      LCurly,
      Literal(
          "value",
      ),
      InnerDelim,
      Literal(
          "RwLock",
      ),
      LParan,
      Literal(
          "PhantomData<stdsyncrwlockRwLock<discretionary_engineexchange_apishubHubToExchange>>",
      ),
      OuterDelim,
      Literal(
          "RwLock",
      ),
      LCurly,
      Literal(
          "data",
      ),
      InnerDelim,
      Literal(
          "HubToExchange",
      ),
      LCurly,
      Literal(
          "key",
      ),
      InnerDelim,
      Literal(
          "0191cc99-b03a-7003-ab4d-ef05bef629ad",
      ),
      OuterDelim,
      Literal(
          "orders",
      ),
      InnerDelim,
      LBrack,
      Literal(
          "Order",
      ),
      LCurly,
      Literal(
          "id",
      ),
      InnerDelim,
      Literal(
          "PositionOrderId",
      ),
      LCurly,
      Literal(
          "position_id",
      ),
      InnerDelim,
      Literal(
          "0191cc99-b039-7960-96d5-3230a8a0a12a",
      ),
      OuterDelim,
      Literal(
          "protocol_id",
      ),
      InnerDelim,
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
      OuterDelim,
      Literal(
          "order_type",
      ),
      InnerDelim,
      Literal(
          "Market",
      ),
      OuterDelim,
      Literal(
          "symbol",
      ),
      InnerDelim,
      Literal(
          "Symbol",
      ),
      LCurly,
      Literal(
          "base",
      ),
      InnerDelim,
      Literal(
          "\"ADA\"",
      ),
      OuterDelim,
      Literal(
          "quote",
      ),
      InnerDelim,
      Literal(
          "\"USDT\"",
      ),
      OuterDelim,
      Literal(
          "market",
      ),
      InnerDelim,
      Literal(
          "BinanceFutures",
      ),
      RCurly,
      OuterDelim,
      Literal(
          "side",
      ),
      InnerDelim,
      Literal(
          "Buy",
      ),
      OuterDelim,
      Literal(
          "qty_notional",
      ),
      InnerDelim,
      Literal(
          "30.78817733990148",
      ),
      RCurly,
      OuterDelim,
      Literal(
          "None",
      ),
      RBrack,
      RCurly,
      RCurly,
      RParan,
      OuterDelim,
      Literal(
          "version",
      ),
      InnerDelim,
      Literal(
          "Version",
      ),
      LParan,
      Literal(
          "2",
      ),
      RParan,
      OuterDelim,
      Literal(
          "is_closed",
      ),
      InnerDelim,
      Literal(
          "false",
      ),
      OuterDelim,
      Literal(
          "ref_count_rx",
      ),
      InnerDelim,
      Literal(
          "1",
      ),
      RCurly,
      OuterDelim,
      Literal(
          "version",
      ),
      InnerDelim,
      Literal(
          "Version",
      ),
      LParan,
      Literal(
          "2",
      ),
      RParan,
      RCurly,
      OuterDelim,
      Literal(
          "last_reported_fill_key",
      ),
      InnerDelim,
      Literal(
          "00000000-0000-0000-0000-000000000000",
      ),
      OuterDelim,
      Literal(
          "currently_deployed",
      ),
      InnerDelim,
      Literal(
          "RwLock",
      ),
      LCurly,
      Literal(
          "data",
      ),
      InnerDelim,
      LBrack,
      RBrack,
      OuterDelim,
      Literal(
          "poisoned",
      ),
      InnerDelim,
      Literal(
          "false",
      ),
      OuterDelim,
      Literal(
          "..",
      ),
      RCurly,
  ]
  "###);

		let ast = tokens_into_ast(tokens)?;
		insta::assert_debug_snapshot!(ast, @r###"
  VecKvp(
      [
          Standard {
              key: Literal(
                  "hub_rx",
              ),
              value: NamedMap(
                  NamedMap {
                      name: Literal(
                          "Receiver",
                      ),
                      contents: [
                          Standard {
                              key: Literal(
                                  "shared",
                              ),
                              value: NamedMap(
                                  NamedMap {
                                      name: Literal(
                                          "Shared",
                                      ),
                                      contents: [
                                          Standard {
                                              key: Literal(
                                                  "value",
                                              ),
                                              value: NamedParams(
                                                  NamedParams {
                                                      name: Literal(
                                                          "RwLock",
                                                      ),
                                                      contents: [
                                                          Literal(
                                                              Literal(
                                                                  "PhantomData<stdsyncrwlockRwLock<discretionary_engineexchange_apishubHubToExchange>>",
                                                              ),
                                                          ),
                                                          NamedMap(
                                                              NamedMap {
                                                                  name: Literal(
                                                                      "RwLock",
                                                                  ),
                                                                  contents: [
                                                                      Standard {
                                                                          key: Literal(
                                                                              "data",
                                                                          ),
                                                                          value: NamedMap(
                                                                              NamedMap {
                                                                                  name: Literal(
                                                                                      "HubToExchange",
                                                                                  ),
                                                                                  contents: [
                                                                                      Standard {
                                                                                          key: Literal(
                                                                                              "key",
                                                                                          ),
                                                                                          value: Literal(
                                                                                              Literal(
                                                                                                  "0191cc99-b03a-7003-ab4d-ef05bef629ad",
                                                                                              ),
                                                                                          ),
                                                                                      },
                                                                                      Standard {
                                                                                          key: Literal(
                                                                                              "orders",
                                                                                          ),
                                                                                          value: Array(
                                                                                              [
                                                                                                  NamedMap(
                                                                                                      NamedMap {
                                                                                                          name: Literal(
                                                                                                              "Order",
                                                                                                          ),
                                                                                                          contents: [
                                                                                                              Standard {
                                                                                                                  key: Literal(
                                                                                                                      "id",
                                                                                                                  ),
                                                                                                                  value: NamedMap(
                                                                                                                      NamedMap {
                                                                                                                          name: Literal(
                                                                                                                              "PositionOrderId",
                                                                                                                          ),
                                                                                                                          contents: [
                                                                                                                              Standard {
                                                                                                                                  key: Literal(
                                                                                                                                      "position_id",
                                                                                                                                  ),
                                                                                                                                  value: Literal(
                                                                                                                                      Literal(
                                                                                                                                          "0191cc99-b039-7960-96d5-3230a8a0a12a",
                                                                                                                                      ),
                                                                                                                                  ),
                                                                                                                              },
                                                                                                                              Standard {
                                                                                                                                  key: Literal(
                                                                                                                                      "protocol_id",
                                                                                                                                  ),
                                                                                                                                  value: Literal(
                                                                                                                                      Literal(
                                                                                                                                          "\"dm\"",
                                                                                                                                      ),
                                                                                                                                  ),
                                                                                                                              },
                                                                                                                              Standard {
                                                                                                                                  key: Literal(
                                                                                                                                      "ordinal",
                                                                                                                                  ),
                                                                                                                                  value: Literal(
                                                                                                                                      Literal(
                                                                                                                                          "0",
                                                                                                                                      ),
                                                                                                                                  ),
                                                                                                                              },
                                                                                                                          ],
                                                                                                                      },
                                                                                                                  ),
                                                                                                              },
                                                                                                              Standard {
                                                                                                                  key: Literal(
                                                                                                                      "order_type",
                                                                                                                  ),
                                                                                                                  value: Literal(
                                                                                                                      Literal(
                                                                                                                          "Market",
                                                                                                                      ),
                                                                                                                  ),
                                                                                                              },
                                                                                                              Standard {
                                                                                                                  key: Literal(
                                                                                                                      "symbol",
                                                                                                                  ),
                                                                                                                  value: NamedMap(
                                                                                                                      NamedMap {
                                                                                                                          name: Literal(
                                                                                                                              "Symbol",
                                                                                                                          ),
                                                                                                                          contents: [
                                                                                                                              Standard {
                                                                                                                                  key: Literal(
                                                                                                                                      "base",
                                                                                                                                  ),
                                                                                                                                  value: Literal(
                                                                                                                                      Literal(
                                                                                                                                          "\"ADA\"",
                                                                                                                                      ),
                                                                                                                                  ),
                                                                                                                              },
                                                                                                                              Standard {
                                                                                                                                  key: Literal(
                                                                                                                                      "quote",
                                                                                                                                  ),
                                                                                                                                  value: Literal(
                                                                                                                                      Literal(
                                                                                                                                          "\"USDT\"",
                                                                                                                                      ),
                                                                                                                                  ),
                                                                                                                              },
                                                                                                                              Standard {
                                                                                                                                  key: Literal(
                                                                                                                                      "market",
                                                                                                                                  ),
                                                                                                                                  value: Literal(
                                                                                                                                      Literal(
                                                                                                                                          "BinanceFutures",
                                                                                                                                      ),
                                                                                                                                  ),
                                                                                                                              },
                                                                                                                          ],
                                                                                                                      },
                                                                                                                  ),
                                                                                                              },
                                                                                                              Standard {
                                                                                                                  key: Literal(
                                                                                                                      "side",
                                                                                                                  ),
                                                                                                                  value: Literal(
                                                                                                                      Literal(
                                                                                                                          "Buy",
                                                                                                                      ),
                                                                                                                  ),
                                                                                                              },
                                                                                                              Standard {
                                                                                                                  key: Literal(
                                                                                                                      "qty_notional",
                                                                                                                  ),
                                                                                                                  value: Literal(
                                                                                                                      Literal(
                                                                                                                          "30.78817733990148",
                                                                                                                      ),
                                                                                                                  ),
                                                                                                              },
                                                                                                          ],
                                                                                                      },
                                                                                                  ),
                                                                                                  Literal(
                                                                                                      Literal(
                                                                                                          "None",
                                                                                                      ),
                                                                                                  ),
                                                                                              ],
                                                                                          ),
                                                                                      },
                                                                                  ],
                                                                              },
                                                                          ),
                                                                      },
                                                                  ],
                                                              },
                                                          ),
                                                      ],
                                                  },
                                              ),
                                          },
                                          Standard {
                                              key: Literal(
                                                  "version",
                                              ),
                                              value: NamedParams(
                                                  NamedParams {
                                                      name: Literal(
                                                          "Version",
                                                      ),
                                                      contents: [
                                                          Literal(
                                                              Literal(
                                                                  "2",
                                                              ),
                                                          ),
                                                      ],
                                                  },
                                              ),
                                          },
                                          Standard {
                                              key: Literal(
                                                  "is_closed",
                                              ),
                                              value: Literal(
                                                  Literal(
                                                      "false",
                                                  ),
                                              ),
                                          },
                                          Standard {
                                              key: Literal(
                                                  "ref_count_rx",
                                              ),
                                              value: Literal(
                                                  Literal(
                                                      "1",
                                                  ),
                                              ),
                                          },
                                      ],
                                  },
                              ),
                          },
                          Standard {
                              key: Literal(
                                  "version",
                              ),
                              value: NamedParams(
                                  NamedParams {
                                      name: Literal(
                                          "Version",
                                      ),
                                      contents: [
                                          Literal(
                                              Literal(
                                                  "2",
                                              ),
                                          ),
                                      ],
                                  },
                              ),
                          },
                      ],
                  },
              ),
          },
          Standard {
              key: Literal(
                  "last_reported_fill_key",
              ),
              value: Literal(
                  Literal(
                      "00000000-0000-0000-0000-000000000000",
                  ),
              ),
          },
          Standard {
              key: Literal(
                  "currently_deployed",
              ),
              value: NamedMap(
                  NamedMap {
                      name: Literal(
                          "RwLock",
                      ),
                      contents: [
                          Standard {
                              key: Literal(
                                  "data",
                              ),
                              value: Array(
                                  [],
                              ),
                          },
                          Standard {
                              key: Literal(
                                  "poisoned",
                              ),
                              value: Literal(
                                  Literal(
                                      "false",
                                  ),
                              ),
                          },
                          RestPattern,
                      ],
                  },
              ),
          },
      ],
  )
  "###);
		Ok(())
	}
}
