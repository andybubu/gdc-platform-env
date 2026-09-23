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

# ANSI Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

ENV_NAME="dev"
ACTION="diff"

usage() {
  echo -e "${BOLD}Usage:${NC} $(basename "$0") [OPTIONS]"
  echo ""
  echo -e "${BOLD}Description:${NC}"
  echo "  Turnkey deployment orchestrator for downstream enterprise tenant platform."
  echo ""
  echo -e "${BOLD}Options:${NC}"
  echo "  -e, --environment <name>  Target environment: dev, stg, or prd (default: dev)"
  echo "  -a, --action <action>     Helmfile action: diff, apply, sync, template, lint (default: diff)"
  echo "  -h, --help                Show this help message"
  echo ""
  echo -e "${BOLD}Examples:${NC}"
  echo "  $(basename "$0") -e dev -a diff      # Inspect planned CRD deltas in dev"
  echo "  $(basename "$0") -e dev -a apply     # Apply reconciliations in dev"
  echo "  $(basename "$0") -e prd -a sync      # Initial bootstrap of production fleet"
  exit 0
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    -e|--environment)
      ENV_NAME="$2"
      shift 2
      ;;
    -a|--action)
      ACTION="$2"
      shift 2
      ;;
    -h|--help)
      usage
      ;;
    *)
      echo -e "${RED}Error: Unknown argument: $1${NC}" >&2
      usage
      ;;
  esac
done

if [[ ! "$ENV_NAME" =~ ^(dev|stg|prd)$ ]]; then
  echo -e "${RED}Error: Invalid environment '$ENV_NAME'. Must be one of: dev, stg, prd.${NC}" >&2
  exit 1
fi

echo -e "${CYAN}====================================================================${NC}"
echo -e "${BOLD} GDC Platform Tenant GitOps — Deployment Pipeline${NC}"
echo -e " Environment: ${GREEN}${ENV_NAME}${NC}"
echo -e " Action:      ${YELLOW}${ACTION}${NC}"
echo -e "${CYAN}====================================================================${NC}"

cd "${REPO_ROOT}"

# Pre-flight check
if ! command -v helmfile &>/dev/null; then
  echo -e "${RED}Error: 'helmfile' is not installed or not in PATH.${NC}" >&2
  exit 1
fi

echo -e "\n${BOLD}Executing:${NC} helmfile -e ${ENV_NAME} ${ACTION} ...\n"
helmfile -e "${ENV_NAME}" "${ACTION}"

echo -e "\n${GREEN}✅ Action '${ACTION}' completed successfully for environment '${ENV_NAME}'.${NC}"
