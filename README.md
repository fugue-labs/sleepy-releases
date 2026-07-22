# sleepy

> Point the Sleepy worker at benchmarked code and get a verified faster version.

Sleepy is an evolutionary code-optimization service with a code-blind hosted
control plane. The service keeps durable run commands, leases, quotas, and
source-free progress. The companion client on your machine owns the search
engine, model session, source, candidates, evaluator, and raw evidence.

The trust boundary is the product:

- The hosted service never receives or executes your source code.
- Your model credentials and provider payloads stay in the client-owned worker.
- Candidate execution and evaluation happen locally in a pinned, fail-closed
  OCI sandbox.
- Every benchmark is guarded by the project's correctness tests, and the final
  champion is re-verified immediately before it can be written.
- The provider-neutral executor/job protocol is the supported product contract.
  MCP sampling is end-of-life and remains only as an explicit compatibility
  adapter outside the code-blind product claim.

This public repository distributes the proprietary companion client. Binaries
are licensed under the [Sleepy Binary License Agreement](EULA.md).

## Quick start

Sign in, create a workspace API key, install a reviewed release, configure your
local model provider, and run the readiness check from a Go checkout:

```bash
open https://sleepy.run/signup
open https://sleepy.run/workspace
export SLEEPY_TOKEN=slpy_...
sleepy doctor --project --server https://sleepy.run
```

Start a hosted run:

```bash
sleepy worker \
  --target ./sort.go \
  --server https://sleepy.run \
  --eval benchmark:BenchmarkSort1000 \
  --population 10 \
  --generations 20
```

The worker computes and binds the evaluator contract, creates the code-blind
hosted run, generates candidates with your configured model, evaluates them
locally behind the restore transaction, and reports only authenticated
source-free decisions.

To optimize changed benchmarked Go files and open an evidence-bearing,
policy-gated pull request through your authenticated GitHub CLI:

```bash
gh auth status
sleepy ci --server https://sleepy.run --base origin/main --create-pr
```

`sleepy ci --create-pr` applies only re-verified wins, commits only those target
files, runs tests and static checks, evaluates API/dependency/unsafe/diff-size/
licensing/provenance gates, pushes once, and opens a PR with measurement and
replay evidence.

## Install

Choose an approved version from [Releases](https://github.com/fugue-labs/sleepy-releases/releases),
download the installer sealed with that exact release, inspect it, and run it:

```bash
version='<reviewed-version>'
curl --proto '=https' --tlsv1.2 -fsSLo install.sh \
  "https://github.com/fugue-labs/sleepy-releases/releases/download/v${version}/install.sh"
less install.sh
SLEEPY_VERSION="${version}" sh install.sh
```

Or install with Homebrew:

```bash
brew install fugue-labs/tap/sleepy
```

Release archives support macOS (Apple Silicon and Intel) and Linux (amd64 and
arm64). Every archive is checksum-bound; current sealed releases also include
SBOM, provenance, manifest, and Sigstore verification material.

## Observe and audit

```bash
sleepy watch <run-id> --server https://sleepy.run
sleepy status <run-id> --server https://sleepy.run
sleepy export <run-id> --server https://sleepy.run --lineage
sleepy export <run-id> --server https://sleepy.run --pareto
```

Cancellation is distinct from convergence: a cancelled run remains available
for export but never auto-applies its current champion.

## Telemetry

The client collects anonymous operational metrics such as command, evaluator
type, language, provider name, duration, and generation count. It does not send
source, local paths, prompts, provider payloads, keys, or raw benchmark output.
Disable telemetry with `SLEEPY_NO_TELEMETRY=1`, `--no-telemetry`, or
`sleepy config set telemetry false`.

## Support and policies

- Start: https://sleepy.run/start
- Status: https://sleepy.run/status
- Support: https://sleepy.run/support
- Privacy: https://sleepy.run/privacy
- Terms: https://sleepy.run/terms

Open public bugs and questions in this repository's issue tracker. Never attach
source code, API keys, OAuth tokens, private run exports, or proprietary
benchmark output to a public issue.
