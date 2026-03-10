#!/bin/bash

# ANSI color codes for styling
RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}[*] Stopping Apoca-llama containers...${NC}"
docker stop ollama1 ollama2 dual-ollama-chat 2>/dev/null || true

echo -e "${CYAN}[*] Removing Apoca-llama containers...${NC}"
docker rm ollama1 ollama2 dual-ollama-chat 2>/dev/null || true

echo -e "${GREEN}[+] Containers successfully stopped and removed.${NC}"
