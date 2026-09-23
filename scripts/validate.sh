#!/usr/bin/env bash
# Copyright 2026 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

GREEN='\033[0;32m'
RED='\033[0;31m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

TARGET_ENV="${1:-all}"

validate_env() {
  local env="$1"
  echo -e "\n${CYAN}====================================================================${NC}"
  echo -e "${BOLD}Validating Environment: ${GREEN}${env}${NC}"
  echo -e "${CYAN}====================================================================${NC}"

  echo -e "${BOLD}[1/2] Linting Helmfile configuration for ${env}...${NC}"
  helmfile -e "${env}" lint

  echo -e "\n${BOLD}[2/2] Validating dynamic Go template rendering for ${env}...${NC}"
  helmfile -e "${env}" template > /dev/null

  echo -e "\n${GREEN}✅ Environment '${env}' passed all linting and templating checks!${NC}"
}

cd "${REPO_ROOT}"

if [[ "${TARGET_ENV}" == "all" ]]; then
  for e in dev stg prd; do
    validate_env "$e"
  done
else
  validate_env "${TARGET_ENV}"
fi

echo -e "\n${GREEN}====================================================================${NC}"
echo -e "${GREEN}${BOLD} ✅ ALL CHECKS PASSED: Tenant platform repository is valid!${NC}"
echo -e "${GREEN}====================================================================${NC}"
