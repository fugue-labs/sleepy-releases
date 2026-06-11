# sleepy

> Point sleepy at a benchmarked codebase, walk away, get a faster version.

![sleepy demo — a real evolution run](demo.gif)

Sleepy is an evolutionary code-optimization engine. You provide a
target source file, a correctness gate (your existing test suite),
and a benchmark. Sleepy iteratively mutates the code via an LLM —
**your** LLM, called with **your** credentials — measures the result,
keeps winners, and discards losers.

The trust model is the point:

- **Your code never leaves your machine.** Evaluation (tests +
  benchmarks) runs locally.
- **Your API keys never leave your machine.** The hosted engine
  orchestrates the search via MCP sampling; it holds no keys and
  executes no user code.
- **Fast-but-wrong is impossible by construction.** Your test suite
  must pass before a benchmark is ever measured; any candidate that
  breaks tests scores zero and is discarded.

This repository hosts binary releases. The source code is
proprietary (© Fugue Labs); binaries are licensed under the
[Sleepy Binary License Agreement](EULA.md).

## How it works

1. **Mutate** — an LLM (yours) proposes a code change via MCP sampling.
2. **Gate** — your test suite must pass; fast-but-wrong scores zero
   and is discarded. This is enforced for every candidate, always.
3. **Measure** — your benchmark scores the survivor.
4. **Select** — winners join the population; evolution repeats.

Every run is auditable after the fact:

```bash
sleepy export <run-id> --lineage   # why the winner won, generation by generation
sleepy replay <run-id> --list      # every candidate the run produced
```

## Install

### One-line install

```bash
curl -fsSL https://raw.githubusercontent.com/fugue-labs/sleepy-releases/main/install.sh | sh
```

The script detects your OS/architecture, downloads the matching
binary from this repo's Releases, verifies its SHA-256 checksum, and
installs to `/usr/local/bin/sleepy` (or `$HOME/.local/bin/sleepy`).
It is intentionally readable — review it first if you like.

### Homebrew

```bash
brew install fugue-labs/tap/sleepy
```

### Manual

Download the archive for your platform from
[Releases](https://github.com/fugue-labs/sleepy-releases/releases),
verify against `checksums.txt`, and put `sleepy` on your `PATH`.

Supported platforms: macOS (Apple Silicon + Intel) and Linux
(amd64 + arm64).

## Quick start

```bash
cd your-project        # any repo with a test suite and a benchmark

export ANTHROPIC_API_KEY=sk-ant-...   # or OPENAI_API_KEY, OLLAMA_HOST,
                                      # Codex OAuth, or `claude` on PATH

sleepy evolve \
  --target ./hot_path.go \
  --eval benchmark:BenchmarkHotPath \
  --population 10 \
  --generations 20
```

Sleepy prints the baseline fitness, per-generation progress, and a
final summary with the measured speedup. Ctrl-C exits cleanly: the
best candidate is exported and your original file restored on error.

Supported evaluators: Go (`test:`/`benchmark:`), Python
(`pytest:`/`pybench:`), Rust (`cargotest:`/`cargobench:`),
JS/TS (`vitest:`/`buntest:`), C++, Zig, Java, or bring your own
runner with `command:./my-script.sh`.

## Telemetry

Sleepy collects anonymous usage metrics (command, evaluator type,
language, provider name, duration, generation count — never source
code, file paths, prompts, or keys). Disable with
`SLEEPY_NO_TELEMETRY=1`, `--no-telemetry`, or
`sleepy config set telemetry false`.

## Support

Open an issue here for bugs and questions:
https://github.com/fugue-labs/sleepy-releases/issues
