# syntax=docker/dockerfile:1.11
FROM scratch
COPY ./target/spin.toml .
COPY ./target/spin-http-ts-example.wasm .
