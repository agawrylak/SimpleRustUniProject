# Stage: chef (base image: lukemathwalker/cargo-chef:latest-rust-slim-buster)
# This stage sets up the base image for building Rust applications and sets the working directory.
FROM rust:1.69-slim-buster AS chef
# We only pay the installation cost once,
# it will be cached from the second build onwards
RUN cargo install cargo-chef
WORKDIR app
# Install pkg-config and libssl-dev (needed for reqwest :<)
RUN apt-get update && apt-get install -y pkg-config libssl-dev

# Stage: planner (base image: chef)
# In this stage, the project directory is copied into the container and the 'cargo chef prepare' command is run
# to generate a recipe file for dependencies.
FROM chef AS planner
COPY . .
RUN cargo chef prepare --recipe-path recipe.json

# Stage: builder (base image: chef)
# The recipe file generated in the previous stage is copied into this stage.
# The 'cargo chef cook' command is run to fetch and build the project's dependencies.
FROM chef AS builder
COPY --from=planner /app/recipe.json recipe.json
RUN cargo chef cook --release --recipe-path recipe.json

# Stage: runtime (base image: rust)
# This stage sets up the runtime environment for the application.
FROM rust AS runtime
WORKDIR /app

# The project directory is copied into the container.
COPY . .

# The compiled target from the builder stage is copied into the runtime stage.
COPY --from=builder /app/target target

# The application is built in release mode using the 'cargo build' command.
RUN cargo build --release --bin artur_gawrylak_sprawozdanie_1

# Stage: final (base image: debian:buster-slim)
# This stage sets up the final image that will be used to run the application.
FROM debian:buster-slim
WORKDIR /app

# Install ca-certificates package
RUN apt-get update && apt-get install -y ca-certificates

# Update the CA certificates
RUN update-ca-certificates

# The compiled binary from the runtime stage is copied into the final image.
COPY --from=runtime /app/target/release/artur_gawrylak_sprawozdanie_1 /usr/local/bin/artur_gawrylak_sprawozdanie_1

# Environment variables are set for the application.
ENV AUTHOR="Artur Gawrylak"
ENV PORT="8000"

# The port 8000 is exposed for the application to listen on.
EXPOSE 8000

# A health check is added to verify the availability of the application.
HEALTHCHECK CMD curl --fail http://localhost:8000/ || exit 1

# The entrypoint command is set to execute the application when the container starts.
ENTRYPOINT ["/usr/local/bin/artur_gawrylak_sprawozdanie_1"]