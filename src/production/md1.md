# Rustのオレオレドキュメント

Status: In progress

Rustの自分なりのドキュメントです。備忘録です。

気になったことを順なので、まとまりはないです。

## vscode で rust-analyzerを利用する場合には、Rust extention option > rust-client.engine: rust-analyzer

- Language Server重い。
- rust-analyzerの方がレイテンシ志向。

# Base

- strはスタックに乗る。固定サイズ、文字列そのものを変更できない。

```rust
let s1 = String::from("hogehoge");
let s2: &str = &s1; //ポインタのコピーだけ
let s3 = s2.to_string(); //メモリの確保
```

- constはコンパイラのビルド時に実際の値に置き換える。staticはバイナリファイルの特定のセクションに配置。
    - なので、コンパイル時に決まらないが、実行時に決まる定数を定義する場合には、 `lazy_static` を使用するのがいい。

### Vector

- vectorアクセスは `get(), get_mut()` を使う。 `vec[2]` だと要素以外にアクセスするとパニックする。

### `format!` 文字列の作成

- フォーマットの定義と、流す値から新しい文字列を作成する。マクロ。

# よく使うマクロ

 [coreのマクロ]([https://doc.rust-lang.org/core/index.html#macros](https://doc.rust-lang.org/core/index.html#macros))

- `vec![]`
- `cfg!` コンパイラから該当のフラグが渡されたらtureになる。
- とりあえずコンパイルを通す時。
    - `unimplemented!` > not implemented, `todo!` > not yet implemented.

### Deriveマクロ

- `{:?}` > std::fmt::Debug(#[derive(Debug)])
- `Default`  `Clone` `Copy` `Hash`
- `Eq/PartialEq` `Ord/PartialOrd`

Eqは `a == a, a ==b なら b == a, a == b &&  b == c なら a == c` を満たす必要がある。浮動小数f32はこの性質を満たさない(0.0/0.0 = non)

条件からa == aを満たさなくてもOKにしたのがPartialEq,

### 宣言マクロ

```rust
macro_rules! five_times {
	($x:expr) => {
		5 * $x
	};
}
```

### 制御構文

- 変数に束縛できる。 `let res = if 0 == hoge {}`
    - loop、if let ,  whileも同様。
- ループ処理はラベルで繰り返しを抜ける場所を指定できる。

```rust
'main: loop {
	hgoehgoe;
	'sub: loop {
		 hogehoge;
		 break 'main;  //mainのループを抜けれる。
	}
}
```

### Box

- Boxは値をヒープに乗せる。
- スマートポインター
- スタックはコンパイル時にサイズが分かっていて、固定長のみ。
- スタックにヒープのポインターを置く。
- 特徴
    - コンパイル時にサイズがわからない型を包む。
    - 大きなサイズの型の値を渡す時に、データの中身をコピーせずに、ポインタを渡す。
    - 共通のトレイトを実装した型をポインタで扱えるつまり、 `dyn`

# OptionやResultをopen, matchするとき

- エラーに何もしなくて、委託する時は `?` オペレーション。
- `expect` はoption型のメソッドで、Someだったら返却、Noneだったら、引数の文字列を返して `panic()` を起こす。
- `let a = bar(n).expect(&format!("n = {}", n));` の場合にはNoneでもformat!をよび、ヒープを確保して文字列を整形する。コスト高い。
- matchでそれぞれのアーム書くか,`if let` で回避できるが冗長。 `unwrap_or_else()` を使う。
- `unwrap_or_else()`  >  `Some = open`,  `None = pass closure`
- `unwrap_or()` は引数をそのまま。
- Resultでも `unwrap_or_else` が使える。

```rust
let r = Some(1223);

let res = match r {
	Some(v) => v,
	None => println!("hogehoge");
}
or  r = Ok(12345);
if let Ok(v) => r {
	pringln!("hogehgoe: {:?}, r);
}

let a = bar(n).unwrap_or_else(|| panic!("n = {}", n));
```

- `anyhow` でも同じく。 `format!()` などで、エラーの整形をするのはコストが高いから、エラーの整形は `with_context` でクロージャを渡す。

```rust
std::fs::open("config.yml").context("Failed to open config file")?;

std::fs::open(path).with_context(|| format!("Failed to open config file: {}", path))?;
```

# match

- 変数束縛
- パターンの網羅
- `_` でパターンのワイルドカード。
- Some(x)に式を当てはめれる。

```rust
let something: Option<i32> = Some(12);

match something {
	Some(x) if x %2 == 0 => , //something 
	Some(x) => ,
	None => ,
}
```

### `map` `and_then` の違い。

- `and_then`は`Some`で包んで返す。
- 関数の返り値がwrapされるときに使い分ける。[detail]([https://cipepser.hatenablog.com/entry/rust-map-and_then](https://cipepser.hatenablog.com/entry/rust-map-and_then))

```rust
pub fn map<U, F: FnOnce(T) -> U>(self, f: F) -> Option<U> {
    match self {
        Some(x) => Some(f(x)),
        None => None,
    }
}

pub fn and_then<U, F: FnOnce(T) -> Option<U>>(self, f: F) -> Option<U> {
    match self {
        Some(x) => f(x),
        None => None,
    }
}
```

# Iterator

- データ集合に対して要素を一つずつ取り出す場合には、 `Iterator` トレイトの実装をしていないといけない。
- `type` `next()` でIteratorを作ることができる。

```rust
struct Iter {
	current: usize,
	max: usize,
}

impl Iterator for Iter {
	type Item = usize,
	
	fn next(&mut self) -> Option<usize> {
		self.current += 1;
		if self.current - 1 < self.max {
			Some(self.currect - 1)
		}
	}
}
```

## vectorアクセス。

- vectorのアクセスはget, get_mutを使用する。直接 vec[1]の様にすると値がなかった場合にパニックになってしまう。なので、しっかりと、optionを返す様にして値がなかった場合にどの様な風にするのかを考えておく。

## into, try_into

## traitにデフォルトを当てられるのか？

特定のアノテーションでそれができそう。

# スレッド

- spawnはクロージャを他のスレッドに持っていって実行。
- クロージャは変数の参照をキャプチャするので、ライフタイムがspawnのほが長生きする可能性がある。→moveさせる。
- vecpushでもspawnできる

```rust
let mut vec = vec![];

for i in 0..10 {
    vec.push(tokio::spawn(async move {
		}
}
```

- message passingと共有メモリ使い分けイメージ

ある共有したい対象がある場合に、権利をタスクに対して渡していくのが共有メモリで、権利を自分で行使するから実装するタスクを渡してっていうのがpassing共有メモリは使用時は権利をブロックするからコストがかかる,passingは実行タスクをキューイングできるからパフォーマンス的に恩恵がある。

# 非同期

- `Future` トレイトを実装した型を戻り値にすることによって実現する。
- ステートマシンであり、readyかpendignのステーを表現してる。
- `Future` ステートマシンは各タスクに対して決まったサイズ、一ヶ所のヒープに `Pin` がされている。メモリも圧迫しない。

- 非同期のライフタイムについて、

```rust
async fn something(arg: &i32) -> i32 {
	*arg
}
//これは以下に展開される。
fn something<'a>(arg: &'a i32) -> impl Future<Output = i32> + 'a {
		async move {
				hogehgoe
		}
}
```

- 問題はスレッドを跨いでFutureの値を贈りたい場合に、’staticライフタイムが必要になってくる。

```rust
fn something() -> impl Future<Output = i32> {
		let value;
		fn func(value);
}
fn func(value: hoge) {
		//ここで別のスレッドに送る処理がある場合。
}
//これはエラーになる。

//asyncブロックでwrapするとライフタイムを解決できる。
fn something() -> impl Future<Output = i32> {
		async {
			let value;
			fn func(value);
		}
}
```

- traitをasyncにしたいなら、 `async-trait`

# 公開について

- 必要な物だけにpubをつける癖をつける。

# testについて

- `#[cfg(test)] mod test{}` を使うと、その中にテストで使うヘルパー関数を中に入れられる。
    
    mod testのなかにテスト用の `use` を入れる。ビルド時には省かれる’。
    
- `cargo-tarpaulin` テストがソースコードをどの程度網羅しているのかを示す指標。
- `cargo-profiler` 各関数呼び出し回数をカウントしたり、キャッシュのヒット率などの情報を取得するプログラム。 `flamegragh` プロファイルを可視化する。 `hyperfine` もベンチマークを取れる。

# Path, PathBuf

- Rustの内部文字列表現は `UTF-8` で持ってるが、OSのもつパスは必ずそうなるとは言えないので、（windowsはUTF-16, C言語互換のヌル終端文字列）Path, PathBufの構造体でpathをもつ。Path = PathBufのスライス。

# Docker

- cacheを使い回す。
- rustのイメージサイズが1.21GB
- muslはシングルバイナリを生成することができ、静的にリンクすることができる。ただ、Dockerでbuildするときは[musl出なくてdebianを使う]([https://andygrove.io/2020/05/why-musl-extremely-slow/](https://andygrove.io/2020/05/why-musl-extremely-slow/))
- リリースイメージにrustのツールチェーンは必要がないのでリリースはdebianのみでいい。

```docker
FROM rust:latest AS builder

//先にtomlのみでビルドをする。
WORKDIR /app
COPY Cargo.toml Cargo.toml 
RUN mkdir src
RUN echo "fn main(){}" > src/main.rs
RUN cargo build --release

//その後にソースを入れてbuild
COPY ./src ./src
RUN rm -f target/release/deps/app*
RUN cargo build --release

FROM debian:10.4

COPY --from=builder /app/target/release/app /usr/local/bin/app
CMD ["app"]
```

# Cargo.lockとrust-toolchainでバージョンを固定。

- `REV=`git rev-parse HEAD` cargo run` でリビジョンを取得できる。特定のリビジョンでbuildを指定することができる。
- `cargo audit` で脆弱性の含まれているcrateを検出できる。
- 脆弱性データベース。[auditはここを参照してる。](https://github.com/RustSec/advisory-db)

# Prometheus
