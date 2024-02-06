# syntax=docker/dockerfile:1.6
FROM scratch
COPY ./target/spin.toml .
COPY ./target/spin-http-ts-example.wasm .
