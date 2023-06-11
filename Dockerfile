# Stage: chef (base image: lukemathwalker/cargo-chef:latest-rust-slim-buster)
FROM lukemathwalker/cargo-chef:latest-rust-slim-buster AS chef
WORKDIR /app

# Install pkg-config and libssl-dev (needed for reqwest :<)
RUN apt-get update && apt-get install -y pkg-config libssl-dev

# Stage: planner (base image: chef)
FROM chef AS planner
COPY . .
RUN cargo chef prepare --recipe-path recipe.json

# Stage: builder (base image: chef)
FROM chef AS builder
COPY --from=planner /app/recipe.json recipe.json
RUN cargo chef cook --release --recipe-path recipe.json

# Stage: runtime (base image: rust)
FROM rust AS runtime
WORKDIR /app

COPY . .

COPY --from=builder /app/target target

RUN cargo build --release --bin artur_gawrylak_sprawozdanie_1

# Stage: final (base image: debian:buster-slim)
FROM debian:buster-slim
WORKDIR /app

RUN apt-get update && apt-get install -y ca-certificates

RUN update-ca-certificates

COPY --from=runtime /app/target/release/artur_gawrylak_sprawozdanie_1 /usr/local/bin/artur_gawrylak_sprawozdanie_1

# Environment variables are set for the application.
ENV AUTHOR="Artur Gawrylak"
ENV PORT="8000"

EXPOSE 8000

HEALTHCHECK CMD curl --fail http://localhost:8000/ || exit 1

ENTRYPOINT ["/usr/local/bin/artur_gawrylak_sprawozdanie_1"]
