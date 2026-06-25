# sleepy

> Connect your agent to the sleepy service. Your own model evolves
> verified-faster code.

![sleepy demo — a real evolution run](demo.gif)

Sleepy is a **hosted evolutionary code-optimization service**, driven
entirely over MCP:

Start here:

```text
https://sleepy.run/start
```

```bash
claude mcp add --transport http sleepy https://sleepy.run/mcp
```

then ask your agent to optimize a benchmarked file. The service
orchestrates an evolutionary search around **your** model: mutations
are generated through MCP sampling (your client, your model, your
credentials), setup happens through MCP elicitation, and every
candidate is evaluated on **your** machine against your real tests and
benchmarks.

The trust model is the point:

- **Your code executes only on your machine.** Evaluation (tests +
  benchmarks) runs locally — the service never executes user code.
- **Your API keys never leave your machine.** The hosted engine
  orchestrates the search via MCP sampling; it holds no keys.
- **Fast-but-wrong is impossible by construction.** Your test suite
  must pass before a benchmark is ever measured; any candidate that
  breaks tests scores zero and is discarded — and the final champion
  is re-verified before it's worth quoting.

This repository hosts the **companion client tooling** for hosted
runs. The source code is proprietary (© Fugue Labs); binaries are
licensed under the [Sleepy Binary License Agreement](EULA.md).

## How a run works

1. **Create** — your MCP client calls `evolve.create` (or the
   zero-argument `evolve.create_interactive`, which collects config
   and the seed through elicitation forms).
2. **Mutate** — the service asks your client for each mutation via
   MCP sampling; your model does the thinking.
3. **Gate** — your test suite must pass; fast-but-wrong scores zero.
   This is enforced for every candidate, always.
4. **Measure** — your benchmark scores the survivor; fitness is
   reported back with `evolve.report`.
5. **Select** — winners join the population; evolution repeats until
   convergence, then `evolve.export` returns the champion.

Your agent can drive that loop itself, or you can hand evaluation to
the worker:

```bash
sleepy worker --target ./hot_path.go --server https://sleepy.run --run <run-id>
```

## Client tooling install

The binaries in this repo are the client half: `worker` (automated
local evaluation), `watch` (live dashboard), `status`, `export`,
`sync`, `inject`, and `doctor`.

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

## Observing runs

```bash
sleepy watch <run-id> --server https://sleepy.run    # live dashboard: spend → gain, lineage
sleepy status <run-id> --server https://sleepy.run
sleepy export <run-id> --server https://sleepy.run --history --format csv
```

Supported evaluators for worker-side measurement: Go
(`test:`/`benchmark:`), Python (`pytest:`/`pybench:`), Rust
(`cargotest:`/`cargobench:`), JS/TS (`vitest:`/`vitestbench:`), C++,
Zig, Java, or bring your own runner with `command:./my-script.sh` —
all gated behind your tests.

## Telemetry

The client collects anonymous usage metrics (command, evaluator type,
language, provider name, duration, generation count — never source
code, file paths, prompts, or keys). Disable with
`SLEEPY_NO_TELEMETRY=1`, `--no-telemetry`, or
`sleepy config set telemetry false`.

## Support

First-run guide:
https://sleepy.run/start

Status:
https://sleepy.run/status

Support guide:
https://sleepy.run/support

Open an issue here for bugs and questions:
https://github.com/fugue-labs/sleepy-releases/issues

Do not include source code, API keys, OAuth tokens, private run
exports, or proprietary benchmark output in public issues.
