################################################################################
# GLOBAL CONFIGURATION VARIABLES
################################################################################
set shell := ["bash", "-e", "-o", "pipefail", "-c"]

# To be used by scripts as the shebang line
BASH := require("bash")

set unstable

# VERSION INFORMATION:
#   Use git describe to form version tag and version number
GIT_DESCRIBE   := `git describe --match "v[0-9]*" --tags`
VERSION_TAG    := env("VERSION_TAG", GIT_DESCRIBE)
VERSION        := env("VERSION", replace(VERSION_TAG, "v", ""))
TARGET_BRANCH  := env("TARGET_BRANCH", `git branch --show-current`)
# HOST ARCHITECTURE:
#   Determine the native architecture
OSARCH        := if arch() == "arm" { "arm64" } else if arch() == "x86_64" { "amd64" } else { arch() }

################################################################################
# HELP TARGET
################################################################################
# help:
#   Display a list of available just targets and provide usage instructions
help:
  @just --list

################################################################################
# HELPER TARGETS
################################################################################
# require-dep DEP INSTALL:
#   Verify that the specified dependency (cmd) is installed
[group('deps')]
_require-dep cmd:
  @{{ if which(cmd) == "" { \
    error("Missing dependency \"" + BOLD + CYAN + cmd + NORMAL + "\". Are you inside devbox? If not using direnv, run '" + BOLD + CYAN + "just shell" + NORMAL + "' to enter a devbox shell. Otherwise, run '" + BOLD + CYAN + "direnv allow'.") \
  } else { "" } }}

# deps:
#   Ensure required tools are installed
[group('deps')]
deps:
  @just _require-dep golangci-lint
  @just _require-dep shfmt

################################################################################
# CLEAN & GENERATION TARGETS
################################################################################
# clean:
#   Remove generated files and build artifacts
[group('clean')]
clean:
  echo "No clean targets defined, skipping"

# generate:
#   Run code generation tasks
[group('generate')]
generate app="true":
  go generate ./...
  @just fmt

alias gen := generate

################################################################################
# LINTING & FORMATTING TARGETS
################################################################################

# ──────────────────────────────────────────────────────────────
# Composite lint targets
# ──────────────────────────────────────────────────────────────

# lint:
#   Run linting tools on the code
[group('lint')]
lint: go-lint sh-lint

# fmt:
#   Run formatting tools on the code
[group('lint')]
fmt: go-fmt sh-lint-fix

# lint-ci:
#   Run linting tools only on the changed code
[group('lint')]
lint-ci: go-lint-ci sh-lint

# lint-fix:
#   Run linting tools with auto-fix enabled
[group('lint')]
lint-fix: go-lint-fix sh-lint-fix

# ──────────────────────────────────────────────────────────────
# Linting sub-targets
# ──────────────────────────────────────────────────────────────

[group('lint')]
[private]
go-lint: deps
	@echo "🔍 Linting    │ main │ golangci-lint"
	@golangci-lint run

[group('lint')]
[private]
go-lint-ci: deps
	#!{{ BASH }}
	echo "🔍 Linting    │ main │ golangci-lint"
	if git diff --name-only HEAD~1 HEAD | grep -Eq '\.go$'; then
		golangci-lint run --fast-only
	else
		echo "ℹ️  Info       │ main │ No Go file changes detected since the last commit."
	fi

[group('lint')]
[private]
go-lint-fix: deps
	@echo "🛠 Fixing     │ main │ golangci-lint"
	@golangci-lint run --fix

[group('lint')]
[private]
go-fmt: deps
	@echo "🛠 Fixing     │ main │ golangci-lint"
	@golangci-lint fmt

[group('lint')]
[private]
sh-lint: deps
	@echo "🔍 Linting    │ main │ shfmt"
	@shfmt -l -d .bin/

[group('lint')]
[private]
sh-lint-fix: deps
	@echo "🛠 Fixing     │ main │ shfmt"
	@shfmt -l -w .bin/

alias sh-fmt := sh-lint-fix

################################################################################
# TESTING TARGETS
################################################################################
# test:
#   Execute the Go test suites
[group('test')]
test:
  go test ./...

# test-race:
#   Execute tests with the race detector enabled
[group('test')]
test-race:
  go test -race ./...

# test-coverage:
#   Run tests with code coverage reporting and generate an HTML report
[group('test')]
test-coverage:
  go test -coverprofile cover.out ./...
  go tool cover -html=cover.out -o coverage.html
  rm -f cover.out

################################################################################
# BUILD TARGETS
################################################################################
# build:
#   Build all cloud components: cloud, cloudmanifest, cloudctl, and cloud-connect
[group('build')]
build: 
  echo "No build targets defined, skipping"

################################################################################
# VERSION INFORMATION
################################################################################
# version:
#   Display version information along with git tag and target branch
version:
  @echo "{{VERSION}} (git_tag={{VERSION_TAG}}, target_branch={{TARGET_BRANCH}})"

################################################################################
# DEVBOX
################################################################################
# devbox:
#   Downloads and install Devbox
[group('devbox')]
devbox:
  @{{ if which("devbox") == "" { "curl -fsSL https://get.jetify.com/devbox | bash" } else { "echo Devbox is already installed. Skipping installation." } }}

# shell:
#   Enters the devbox shell
[group('devbox')]
shell: devbox
  @devbox shell
