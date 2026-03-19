.PHONY: build run

build:
	cd codex-rs && cargo build --bin codex

run:
	cd codex-rs && cargo run --bin codex -- $(ARGS)
