#!/bin/bash

# ANSI color codes for styling
RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}[!] Warning: This will delete all containers, networks, volumes, and images associated with Apoca-llama!${NC}"

echo -e "${CYAN}[*] Stopping containers...${NC}"
docker stop ollama1 ollama2 dual-ollama-chat 2>/dev/null || true

echo -e "${CYAN}[*] Removing containers...${NC}"
docker rm ollama1 ollama2 dual-ollama-chat 2>/dev/null || true

echo -e "${CYAN}[*] Removing Docker network...${NC}"
docker network rm dual-ollama-network 2>/dev/null || true

echo -e "${CYAN}[*] Removing Docker volumes (wiping downloaded models)...${NC}"
docker volume rm ollama1_data ollama2_data 2>/dev/null || true

echo -e "${CYAN}[*] Removing images...${NC}"
docker rmi dual-ollama-chat-ui 2>/dev/null || true
docker rmi ollama/ollama 2>/dev/null || true

echo -e "${GREEN}[+] Apoca-llama project successfully deleted from the Docker daemon.${NC}"
