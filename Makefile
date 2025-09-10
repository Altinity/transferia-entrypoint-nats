
# removes static build artifacts
.PHONY: clean
clean:
	@echo "--------------> Running 'make clean'"
	@rm -rf binaries tmp

# Define the `build` target
API ?= trcli

.PHONY: build
build:
	go build -ldflags="-w" -o  binaries/$(API) ./cmd/trcli/*.go