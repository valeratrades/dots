use clap::Parser;
use statrs::distribution::{ContinuousCDF, Normal};

/// `std <-> percent` converter
#[derive(Parser, Debug)]
#[command(author, version, about, long_about = None)]
struct Args {
    /// Value of the range.
    /// if v < 20 : std_to_percent() : percent_to_std()
    #[arg(value_parser)]
    to_convert: f64,
}

fn main() {
    let args = Args::parse();

    let n = Normal::new(0.0, 1.0).unwrap();
    let converted: f64 = {
        if args.to_convert < 20.0 {
            let cp = n.cdf(args.to_convert) - n.cdf(-args.to_convert);
            cp * 100.0
        } else {
            let z = n.inverse_cdf(1.0 - (100.0 - args.to_convert) / 200.0);
            (z * 10.0).round() / 10.0
        }
    };
    println!("{}", converted);
}
