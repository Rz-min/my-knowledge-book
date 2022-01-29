FROM debian:buster-slim as runner

RUN apt update; apt install -y libssl1.1

FROM rust:latest as builder

WORKDIR /usr/src

RUN rustup target add x86_64-unknown-linux-musl

RUN cargo install mdbook --vers "^0.3.5"

EXPOSE 3000

WORKDIR /mdbook

# FROM debian:buster-slim as runner

# RUN apt update; apt install -y libssl1.1

# FROM rust:1.48.0 as builder

# WORKDIR /usr/src

# RUN rustup target add x86_64-unknown-linux-musl

# COPY Cargo.toml Cargo.lock ./
# COPY src ./src

# RUN --mount=type=cache,target=/usr/local/cargo/registry \
#     --mount=type=cache,target=/usr/src/target \
#     cargo install --path .

# FROM runner

# COPY --from=builder /usr/local/cargo/bin/myapp .
# COPY Rocket.toml .

# USER 1000

# CMD ["./myapp"]