# Sleepy Binary License Agreement (Beta)

Copyright © 2026 Fugue Labs. All rights reserved.

This agreement governs your use of the sleepy command-line binary
and related release artifacts ("the Software") distributed by Fugue
Labs. By downloading, installing, or using the Software you agree to
these terms. If you do not agree, do not use the Software.

## 1. License grant

Fugue Labs grants you a personal, worldwide, non-exclusive,
non-transferable, revocable license to download, install, and run
unmodified copies of the Software, free of charge during the beta
period, for the purpose of optimizing code and other artifacts you
are authorized to work on — including in commercial settings.

## 2. Restrictions

You may not, except to the extent a restriction is unenforceable
under applicable law:

- redistribute, sell, rent, sublicense, or host the Software for
  third parties;
- modify, translate, decompile, disassemble, or reverse-engineer
  the Software, or attempt to derive its source code;
- use the Software to build, train, or improve a competing
  evolutionary code-optimization product or service;
- remove or alter proprietary notices in the Software or its
  release artifacts.

The Software's source code is proprietary and is not licensed to
you under this agreement.

## 3. Your code and your credentials

The Software runs candidate generation and evaluations on your machine,
calls your selected LLM provider using your credentials, and keeps source,
candidates, prompts, provider payloads, raw measurements, and replay evidence
in the client-owned executor. When you use the canonical hosted executor/job
service, the client sends source-free scheduling commands and authenticated
decision projections for durable orchestration. The hosted service does not
receive or execute your source code, does not receive model-provider API keys,
and does not use customer artifacts or outcomes for shared or cross-workspace
learning. The explicitly selected, end-of-life MCP compatibility adapter is
outside this code-blind product claim. Anonymous usage telemetry is collected
as described in the Software's first-run notice and can be disabled
(`SLEEPY_NO_TELEMETRY=1`, `--no-telemetry`, or
`sleepy config set telemetry false`).

## 4. Third-party components

The Software includes open-source components licensed under their
own terms. Their notices are provided in the release artifacts and
remain governed by their respective licenses.

## 5. No warranty

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING MERCHANTABILITY, FITNESS FOR A
PARTICULAR PURPOSE, AND NON-INFRINGEMENT. The Software modifies
source files in directories you point it at; maintain version
control and review every change it proposes.

## 6. Limitation of liability

TO THE MAXIMUM EXTENT PERMITTED BY LAW, FUGUE LABS SHALL NOT BE
LIABLE FOR ANY INDIRECT, INCIDENTAL, SPECIAL, CONSEQUENTIAL, OR
EXEMPLARY DAMAGES, OR FOR LOSS OF DATA, PROFITS, OR REVENUE,
ARISING FROM OR RELATED TO YOUR USE OF THE SOFTWARE.

## 7. Termination

This license terminates automatically if you breach it. Fugue Labs
may discontinue beta distribution at any time. Sections 2 and 4-8
survive termination.

## 8. General

This agreement is governed by the laws of the State of Delaware,
USA, excluding its conflict-of-law rules. It is the entire
agreement regarding the Software and supersedes prior terms. If any
provision is unenforceable, the remainder stays in effect.

Contact: trevor.prater@gmail.com
