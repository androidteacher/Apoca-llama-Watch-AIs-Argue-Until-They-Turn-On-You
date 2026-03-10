#!/bin/bash

# ANSI color codes for styling
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}================================================================${NC}"
echo -e "${GREEN}                 Dual-Ollama Setup Script                       ${NC}"
echo -e "${CYAN}================================================================${NC}"

# Check for Docker
if ! command -v docker &> /dev/null; then
    echo -e "${RED}[!] Docker is not installed. Please install docker first.${NC}"
    exit 1
fi

echo -e "${CYAN}[*] Creating docker network...${NC}"
docker network create dual-ollama-network 2>/dev/null || true

echo -e "\n${CYAN}[*] Starting Ollama container 1...${NC}"
docker run -d \
  --network dual-ollama-network \
  -v ollama1_data:/root/.ollama \
  -p 11434:11434 \
  -e OLLAMA_ORIGINS="*" \
  --name ollama1 \
  ollama/ollama

if [ $? -ne 0 ]; then
    echo -e "${YELLOW}[!] Failed to start ollama1. It may already be running.${NC}"
fi

echo -e "\n${CYAN}[*] Starting Ollama container 2...${NC}"
# Note: Host port is 11435 to avoid conflict with ollama1
docker run -d \
  --network dual-ollama-network \
  -v ollama2_data:/root/.ollama \
  -p 11435:11434 \
  -e OLLAMA_ORIGINS="*" \
  --name ollama2 \
  ollama/ollama

if [ $? -ne 0 ]; then
    echo -e "${YELLOW}[!] Failed to start ollama2. It may already be running.${NC}"
fi

echo -e "\n${CYAN}[*] Waiting for Ollama services to become ready...${NC}"
sleep 10

echo -e "\n${CYAN}[*] Pulling default model (qwen2.5:3b) on Server 1...${NC}"
docker exec -d ollama1 ollama pull qwen2.5:3b

echo -e "\n${CYAN}[*] Pulling default model (qwen2.5:3b) on Server 2...${NC}"
docker exec -d ollama2 ollama pull qwen2.5:3b


SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo -e "\n${CYAN}[*] Building the Chat Web UI container...${NC}"
docker build -t dual-ollama-chat-ui "$SCRIPT_DIR/web"

if [ $? -ne 0 ]; then
    echo -e "${RED}[!] Failed to build the Chat UI image.${NC}"
    exit 1
fi

echo -e "\n${CYAN}[*] Starting the Chat Web UI on port 8889...${NC}"
docker run -d \
  --network dual-ollama-network \
  --name dual-ollama-chat \
  -p 8889:80 \
  dual-ollama-chat-ui

if [ $? -ne 0 ]; then
    echo -e "${RED}[!] Failed to start the Chat UI container.${NC}"
    exit 1
fi

echo -e "${GREEN}[+] Dual-Ollama Chat UI is running! Access at http://localhost:8889${NC}"
