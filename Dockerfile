# syntax=docker/dockerfile:1.6
FROM scratch
COPY ./target/spin.toml .
COPY ./target/spin-http-ts-example.wasm .
ARG HELLO_SOURCE_URL
ARG HELLO_REVISION
LABEL org.opencontainers.image.source="$HELLO_SOURCE_URL"
LABEL org.opencontainers.image.revision="$HELLO_REVISION"
LABEL org.opencontainers.image.description="Example Spin HTTP Application written in TypeScript"
LABEL org.opencontainers.image.licenses="ISC"
