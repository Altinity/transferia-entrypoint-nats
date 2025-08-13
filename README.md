# Go Project Template

This repository is a comprehensive template for building production-ready Go applications. It comes pre-configured with a suite of tools and workflows to enforce best practices, automate common development tasks, and streamline the CI/CD process.

## Getting Started

To initialize a new project from this template, use the `goinit` script. This script automates the setup process.

**Prerequisites:**

- The `just` command-line tool must be installed. You can find installation instructions at [https://github.com/casey/just](https://github.com/casey/just).

**Initialization Steps:**

1. **Run the Initialization Script:**
    Execute the `goinit` script from the `.bin` directory, providing your desired project name.

    If you're using direnv, the `.bin` directory should already be in your PATH.

```bash
goinit <repository-name>
```

For example:

```bash
goinit my-new-app
```

2. **Activate Development Environment:**
This project uses `direnv` and `devbox` to manage the development environment. After the `goinit` script completes, enable the environment by running:

```bash
direnv allow
```

This will install all necessary dependencies defined in `devbox.json`.

## Available Commands

This project uses a `justfile` to provide a set of commands for automating common development tasks.

| Command | Description |
| :--- | :--- |
| `help` | Displays a list of all available `just` commands. |
| `deps` | Checks that all required dependencies are installed. |
| `clean` | Removes generated files and build artifacts. |
| `generate` (or `gen`) | Runs Go code generation and formats the code. |
| `lint` | Runs all linters on the codebase. |
| `lint-ci` | A CI-optimized linting command that only checks changed files. |
| `lint-fix` | Runs linters with the `--fix` flag to automatically correct issues. |
| `fmt` | Formats Go code. |
| `test` | Executes the Go test suite for all packages. |
| `test-race` | Runs tests with the Go race detector enabled. |
| `test-coverage` | Runs tests and generates a code coverage report. |
| `build` | A placeholder for building project components. |
| `version` | Displays the current project version based on the latest Git tag. |
| `devbox` | Installs the Devbox tool if it is not already present. |
| `shell` | Enters a `devbox` shell with all project dependencies. |

## CI/CD Pipeline

The repository is equipped with a CI/CD pipeline that automates testing, security analysis, and releases.

### Testing (`test.yml`)

- **Trigger:** Runs on every push to `main` and on every pull request.
- **Process:**
    1. Checks out the code.
    2. Sets up the Go environment.
    3. Runs code generation and tests.
    4. Uploads test results as a workflow artifact.

### Security (`security.yml`)

- **Trigger:** Runs on push to `main` and on pull requests.
- **Jobs:**
  - **SAST (Static Application Security Testing):** Uses `golangci-lint` to perform static analysis.
  - **SCA (Software Composition Analysis):** Uses `govulncheck` to scan for vulnerabilities in dependencies.

### Releases (`release.yml`)

- **Trigger:** Manual or on a `workflow_call` with a specified Git tag.
- **Process:**
    1. Checks out the specified Git tag.
    2. Sets up Go, QEMU, and Docker Buildx.
    3. Logs into DockerHub.
    4. Runs `GoReleaser` to build release artifacts, create a GitHub Release, and publish Docker images.
