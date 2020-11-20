#!/bin/bash

# Format all scripts.

set -euo pipefail
IFS=$'\n\t'

cd "$(cd "$(dirname "${0}")" && pwd)"/..

shfmt -l -w ./**/*.sh

clang-format -i ./*/*.js
