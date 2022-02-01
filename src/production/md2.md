# Today

- structにderive macroすることでこのstructにパーサの設定を渡せる。

```rust
#[derive(StructOpt, Debug)]
pub struct Opt {}
```

- PathBufを受け取りたい場合。

```rust
#[structopt(short = "c", long = "csv_url", parse(from_os_str))]
    pub csv_path: PathBuf,
```

command

`./target/debug/curl_and_request -c gheohgeo -u hogegeo`

すごくシンプルに

```rust
//
use structopt::{clap::{self, arg_enum}, StructOpt};
use std::path::PathBuf;

#[derive(StructOpt, Debug)]
#[structopt(name = "example")]
#[structopt(long_version(option_env!("LONG_VERSION").unwrap_or(env!("CARGO_PKG_VERSION"))))] //git のリビジョン
#[structopt(setting(clap::AppSettings::ColoredHelp))] //put color
pub struct Opt {
    #[structopt(short = "c", long = "csv_url")]
    pub csv_path: PathBuf,
    #[structopt(short = "u", long = "url")]
    pub url: String,
    #[structopt(short = "h", long = "cmd")]
    pub cmd: Cmd,
}

arg_enum! {
    #[derive(Debug)]
    pub enum Cmd {
        A,
        B,
        C,
    }
}

//subcommandのもちかた
//#[struct(subcommand)]でもつ
#[derive(Debug, StructOpt)]
pub enum Sub {
    #[structopt(name = "sub1", about = "sub command1")]
    #[structopt(setting(clap::AppSettings::ColoredHelp))]
    Sub1,
}

fn main() {
    let opt = Opt::from_args();
    println!("{:?}", opt);
}

`./target/debug/curl_and_request -h A -c gheohgeo -u hogegeo`
```

# hyper

- `Request::builder()`を使うことで非常に簡単にヘッダー付きのリクエストを生成することができます。

```rust
let req = Request::builder()
.method(Method::POST)
.uri("http://httpbin.org/post")
.header("content-type", "application/json")
.body(Body::from(r#"{"library":"hyper"}"#))?;
```