#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"
pnpm install --frozen-lockfile
pnpm --dir test/all-pure install --frozen-lockfile
pnpm run test:types
pnpm run test:suite
pnpm run test:integ
