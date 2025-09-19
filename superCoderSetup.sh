#!/bin/bash

set -euo pipefail

# Color codes for better output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color
BOLD='\033[1m'

# Status icons
CHECK="✓"
CROSS="✗"
ARROW="→"
INFO="ℹ"

# Global variables for tracking status
NODEJS_INSTALLED=false
DOCKER_INSTALLED=false
DOCKER_COMPOSE_INSTALLED=false
CLAUDE_CLI_INSTALLED=false
MEMORY_BANK_RUNNING=false

# Configuration storage
CONFIG_FILE="$HOME/.supercoder_config"

# Function to print colored output
print_color() {
    local color=$1
    shift
    echo -e "${color}$*${NC}"
}

# Function to print section headers
print_header() {
    echo
    print_color "$BLUE" "╔════════════════════════════════════════════════════════════════╗"
    print_color "$BLUE" "║  $1"
    print_color "$BLUE" "╚════════════════════════════════════════════════════════════════╝"
    echo
}

# Function to print status
print_status() {
    local status=$1
    local message=$2
    if [ "$status" = "ok" ]; then
        print_color "$GREEN" "  $CHECK $message"
    elif [ "$status" = "missing" ]; then
        print_color "$RED" "  $CROSS $message"
    elif [ "$status" = "info" ]; then
        print_color "$CYAN" "  $INFO $message"
    elif [ "$status" = "warning" ]; then
        print_color "$YELLOW" "  ⚠ $message"
    fi
}

# Function to ask yes/no questions
ask_yes_no() {
    local prompt=$1
    local default=${2:-"y"}
    local response
    
    if [ "$default" = "y" ]; then
        prompt="$prompt [Y/n]: "
    else
        prompt="$prompt [y/N]: "
    fi
    
    read -p "$prompt" response
    response=${response:-$default}
    
    if [[ "$response" =~ ^[Yy]$ ]]; then
        return 0
    else
        return 1
    fi
}

# Function to get user input with default value
get_input() {
    local prompt=$1
    local default=$2
    local response
    
    if [ -n "$default" ]; then
        read -p "$prompt [$default]: " response
        echo "${response:-$default}"
    else
        read -p "$prompt: " response
        echo "$response"
    fi
}

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to save configuration
save_config() {
    local key=$1
    local value=$2
    
    # Create config file if it doesn't exist
    touch "$CONFIG_FILE"
    
    # Remove existing key if present
    sed -i "/^$key=/d" "$CONFIG_FILE" 2>/dev/null || true
    
    # Add new key-value pair
    echo "$key=$value" >> "$CONFIG_FILE"
}

# Function to load configuration
load_config() {
    local key=$1
    local default=$2
    
    if [ -f "$CONFIG_FILE" ]; then
        local value=$(grep "^$key=" "$CONFIG_FILE" 2>/dev/null | cut -d'=' -f2-)
        echo "${value:-$default}"
    else
        echo "$default"
    fi
}

# Function to check prerequisites
check_prerequisites() {
    print_header "System Status Check"
    
    # Check Node.js
    if command_exists node && command_exists npm && command_exists npx; then
        NODEJS_INSTALLED=true
        local node_version=$(node -v)
        print_status "ok" "Node.js installed: $node_version"
    else
        print_status "missing" "Node.js, npm, or npx not found"
    fi
    
    # Check Docker
    if command_exists docker; then
        if docker info >/dev/null 2>&1; then
            DOCKER_INSTALLED=true
            local docker_version=$(docker --version | cut -d' ' -f3 | sed 's/,$//')
            print_status "ok" "Docker installed and running: $docker_version"
        else
            print_status "warning" "Docker installed but not accessible (may need sudo or group membership)"
            DOCKER_INSTALLED=false
        fi
    else
        print_status "missing" "Docker not installed"
    fi
    
    # Check Docker Compose
    if docker compose version >/dev/null 2>&1; then
        DOCKER_COMPOSE_INSTALLED=true
        local compose_version=$(docker compose version --short 2>/dev/null || echo "unknown")
        print_status "ok" "Docker Compose installed: $compose_version"
    else
        print_status "missing" "Docker Compose not installed"
    fi
    
    # Check Claude CLI
    if command_exists claude; then
        CLAUDE_CLI_INSTALLED=true
        print_status "ok" "Claude CLI installed"
    else
        print_status "missing" "Claude CLI not installed"
    fi
    
    # Check Memory Bank status
    if [ "$DOCKER_INSTALLED" = true ]; then
        if docker ps --format '{{.Names}}' | grep -q '^memory-bank$'; then
            if curl -sfS http://localhost:8080 >/dev/null 2>&1; then
                MEMORY_BANK_RUNNING=true
                print_status "ok" "Memory Bank server is running"
            else
                print_status "warning" "Memory Bank container running but API not responding"
            fi
        else
            print_status "info" "Memory Bank server not running"
        fi
    fi
}

# Function to check installed MCP servers
check_mcp_servers() {
    if [ "$CLAUDE_CLI_INSTALLED" = false ]; then
        return
    fi
    
    print_header "MCP Servers Status"
    
    local servers=("context7" "filesystem" "sequential-thinking" "fetch" "tavily" "gitmcp" "obsidian" "kg-memory" "memory-bank")
    
    for server in "${servers[@]}"; do
        if claude mcp info "$server" >/dev/null 2>&1; then
            print_status "ok" "$server configured"
        else
            print_status "missing" "$server not configured"
        fi
    done
}

# Function to install Node.js
install_nodejs() {
    print_header "Installing Node.js LTS"
    
    print_status "info" "Installing Node.js, npm, and npx..."
    sudo apt-get update
    sudo apt-get install -y curl ca-certificates
    curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
    sudo apt-get install -y nodejs
    
    if command_exists node && command_exists npm && command_exists npx; then
        print_status "ok" "Node.js installation successful!"
        NODEJS_INSTALLED=true
    else
        print_status "missing" "Node.js installation failed"
        return 1
    fi
}

# Function to install Docker
install_docker() {
    print_header "Installing Docker"
    
    print_status "info" "Installing Docker Engine..."
    curl -fsSL https://get.docker.com | sh
    
    print_status "info" "Adding current user to docker group..."
    sudo usermod -aG docker "$USER"
    
    print_status "warning" "You need to log out and back in for docker group changes to take effect"
    print_status "info" "Alternatively, run: newgrp docker"
    
    if ask_yes_no "Would you like to activate docker group now? (starts new shell)"; then
        newgrp docker
    fi
    
    DOCKER_INSTALLED=true
}

# Function to install Docker Compose
install_docker_compose() {
    print_header "Installing Docker Compose"
    
    print_status "info" "Installing Docker Compose plugin..."
    sudo apt-get update
    sudo apt-get install -y docker-compose-plugin
    
    if docker compose version >/dev/null 2>&1; then
        print_status "ok" "Docker Compose installation successful!"
        DOCKER_COMPOSE_INSTALLED=true
    else
        print_status "missing" "Docker Compose installation failed"
        return 1
    fi
}

# Function to setup Memory Bank
setup_memory_bank() {
    print_header "Setting up Memory Bank Server"
    
    if [ "$DOCKER_INSTALLED" = false ]; then
        print_status "missing" "Docker is required for Memory Bank. Please install Docker first."
        return 1
    fi
    
    print_status "info" "Cloning Memory Bank repository..."
    if [ ! -d "$HOME/memory-bank-mcp" ]; then
        cd "$HOME" && git clone https://github.com/alioshr/memory-bank-mcp.git
    else
        print_status "info" "Memory Bank repository already exists"
    fi
    
    cd "$HOME/memory-bank-mcp"
    
    print_status "info" "Starting Memory Bank server..."
    if [ "$DOCKER_COMPOSE_INSTALLED" = true ] && { [ -f docker-compose.yml ] || [ -f compose.yml ]; }; then
        docker compose up -d
    else
        docker build -t memory-bank-mcp .
        docker run -d \
            --name memory-bank \
            -p 8080:8080 \
            -e MEMORY_BANK_STORAGE_DIR=/data \
            -v memory-bank-data:/data \
            --restart unless-stopped \
            memory-bank-mcp
    fi
    
    print_status "info" "Waiting for Memory Bank to start..."
    sleep 5
    
    if curl -sfS http://localhost:8080 >/dev/null 2>&1; then
        print_status "ok" "Memory Bank server is running!"
        MEMORY_BANK_RUNNING=true
    else
        print_status "warning" "Memory Bank may still be starting. Check with: docker logs memory-bank"
    fi
    
    cd - >/dev/null
}

# Function to get API key with instructions
get_api_key() {
    local service=$1
    local env_var=$2
    local instructions=$3
    local current_value=$(load_config "$env_var" "")
    
    echo
    print_color "$CYAN" "Setting up $service"
    print_color "$YELLOW" "$instructions"
    echo
    
    if [ -n "$current_value" ]; then
        if ask_yes_no "Use existing API key? (${current_value:0:10}...)" "y"; then
            echo "$current_value"
            return
        fi
    fi
    
    local api_key=""
    while [ -z "$api_key" ]; do
        api_key=$(get_input "Enter your $service API key" "")
        if [ -z "$api_key" ]; then
            if ask_yes_no "Skip $service setup?" "n"; then
                echo "SKIP"
                return
            fi
        fi
    done
    
    save_config "$env_var" "$api_key"
    echo "$api_key"
}

# Function to configure MCP server
configure_mcp_server() {
    local server_name=$1
    local server_cmd=$2
    shift 2
    local env_args=("$@")
    
    print_color "$CYAN" "Configuring $server_name..."
    
    # Build the command
    local cmd="claude mcp add $server_name"
    for env_arg in "${env_args[@]}"; do
        cmd="$cmd -e $env_arg"
    done
    cmd="$cmd -- $server_cmd"
    
    # Execute the command
    eval "$cmd"
    
    if claude mcp info "$server_name" >/dev/null 2>&1; then
        print_status "ok" "$server_name configured successfully!"
    else
        print_status "warning" "$server_name configuration may have failed"
    fi
}

# Function to setup individual MCP servers
setup_mcp_servers() {
    print_header "MCP Server Configuration"
    
    if [ "$CLAUDE_CLI_INSTALLED" = false ]; then
        print_status "missing" "Claude CLI is required. Please install it first:"
        print_status "info" "Visit: https://github.com/anthropics/claude-cli"
        return 1
    fi
    
    # Context7
    if ! claude mcp info context7 >/dev/null 2>&1; then
        if ask_yes_no "Configure Context7 MCP? (for version-specific docs)" "y"; then
            local context7_key=$(get_api_key "Context7" "CONTEXT7_API_KEY" \
                "To get a Context7 API key:\n  1. Visit: https://context7.ai\n  2. Sign up for an account\n  3. Go to API settings\n  4. Generate a new API key")
            
            if [ "$context7_key" != "SKIP" ]; then
                configure_mcp_server "context7" "npx -y @upstash/context7-mcp@latest" \
                    "CONTEXT7_API_KEY=$context7_key"
            fi
        fi
    fi
    
    # Filesystem
    if ! claude mcp info filesystem >/dev/null 2>&1; then
        if ask_yes_no "Configure Filesystem MCP? (for file access)" "y"; then
            local default_paths="/workspace,$HOME/projects"
            local fs_paths=$(get_input "Enter allowed paths (comma-separated)" "$default_paths")
            local readonly=$(ask_yes_no "Make filesystem read-only?" "n" && echo "true" || echo "false")
            
            configure_mcp_server "filesystem" "npx -y @modelcontextprotocol/server-filesystem@latest" \
                "FS_ALLOWED_PATHS=$fs_paths" \
                "FS_READONLY=$readonly"
        fi
    fi
    
    # Sequential Thinking
    if ! claude mcp info sequential-thinking >/dev/null 2>&1; then
        if ask_yes_no "Configure Sequential Thinking MCP? (for complex reasoning)" "y"; then
            local max_steps=$(get_input "Maximum thinking steps" "12")
            
            configure_mcp_server "sequential-thinking" "npx -y @modelcontextprotocol/server-sequential-thinking@latest" \
                "SEQ_MAX_STEPS=$max_steps"
        fi
    fi
    
    # Fetch
    if ! claude mcp info fetch >/dev/null 2>&1; then
        if ask_yes_no "Configure Fetch MCP? (for web documentation)" "y"; then
            configure_mcp_server "fetch" "npx -y @modelcontextprotocol/server-fetch@latest" \
                "FETCH_TIMEOUT_MS=20000" \
                "FETCH_MAX_LENGTH=500000"
        fi
    fi
    
    # Tavily
    if ! claude mcp info tavily >/dev/null 2>&1; then
        if ask_yes_no "Configure Tavily MCP? (for web search)" "y"; then
            local tavily_key=$(get_api_key "Tavily" "TAVILY_API_KEY" \
                "To get a Tavily API key:\n  1. Visit: https://tavily.com\n  2. Sign up for a free account\n  3. Go to API Keys section\n  4. Copy your API key")
            
            if [ "$tavily_key" != "SKIP" ]; then
                configure_mcp_server "tavily" "npx -y @tavilyai/mcp-server@latest" \
                    "TAVILY_API_KEY=$tavily_key" \
                    "TAVILY_MAX_RESULTS=5"
            fi
        fi
    fi
    
    # GitMCP
    if ! claude mcp info gitmcp >/dev/null 2>&1; then
        if ask_yes_no "Configure GitMCP? (for Git awareness)" "y"; then
            local repo_path=$(get_input "Git repository path" "/workspace/repo")
            local default_branch=$(get_input "Default branch" "main")
            local allow_write=$(ask_yes_no "Allow Git write operations?" "n" && echo "true" || echo "false")
            
            configure_mcp_server "gitmcp" "npx -y gitmcp@latest" \
                "GIT_REPO_PATH=$repo_path" \
                "GIT_DEFAULT_BRANCH=$default_branch" \
                "GIT_ALLOW_WRITE=$allow_write"
        fi
    fi
    
    # Obsidian
    if ! claude mcp info obsidian >/dev/null 2>&1; then
        if ask_yes_no "Configure Obsidian MCP? (for knowledge base)" "y"; then
            print_status "info" "Make sure you have an Obsidian vault on this system"
            local vault_path=$(get_input "Obsidian vault path" "$HOME/Obsidian/MyVault")
            local readonly=$(ask_yes_no "Make Obsidian read-only?" "y" && echo "true" || echo "false")
            
            configure_mcp_server "obsidian" "npx -y mcp-obsidian@latest" \
                "OBSIDIAN_VAULT_PATH=$vault_path" \
                "OBSIDIAN_READONLY=$readonly"
        fi
    fi
    
    # Knowledge Graph Memory
    if ! claude mcp info kg-memory >/dev/null 2>&1; then
        if ask_yes_no "Configure Knowledge Graph Memory MCP?" "y"; then
            local db_path=$(get_input "Database path" "/workspace/.kgmcp/db.sqlite")
            local max_nodes=$(get_input "Maximum nodes" "50000")
            
            configure_mcp_server "kg-memory" "npx -y mcp-knowledge-graph@latest" \
                "KG_DB_PATH=$db_path" \
                "KG_MAX_NODES=$max_nodes"
        fi
    fi
    
    # Memory Bank
    if ! claude mcp info memory-bank >/dev/null 2>&1; then
        if ask_yes_no "Configure Memory Bank MCP? (persistent memory)" "y"; then
            if [ "$MEMORY_BANK_RUNNING" = false ]; then
                print_status "warning" "Memory Bank server is not running"
                if ask_yes_no "Set up Memory Bank server first?" "y"; then
                    setup_memory_bank
                fi
            fi
            
            local namespace=$(get_input "Project namespace" "default-project")
            
            configure_mcp_server "memory-bank" "npx -y memory-bank-mcp@latest" \
                "MEMORY_BANK_URL=http://localhost:8080" \
                "MEMORY_NAMESPACE=$namespace"
        fi
    fi
}

# Function to show main menu
show_menu() {
    print_header "SuperCoder MCP Setup - Main Menu"
    
    echo "1) Check system status"
    echo "2) Install prerequisites (Node.js, Docker)"
    echo "3) Set up Memory Bank server"
    echo "4) Configure MCP servers"
    echo "5) Run complete setup (all of the above)"
    echo "6) Verify MCP server connections"
    echo "7) Show troubleshooting help"
    echo "0) Exit"
    echo
}

# Function to show troubleshooting help
show_troubleshooting() {
    print_header "Troubleshooting Guide"
    
    print_color "$CYAN" "Common Issues and Solutions:"
    echo
    
    print_color "$YELLOW" "Docker permission denied:"
    echo "  - Run: newgrp docker"
    echo "  - Or logout and login again"
    echo
    
    print_color "$YELLOW" "Memory Bank not responding:"
    echo "  - Check logs: docker logs memory-bank"
    echo "  - Restart: docker restart memory-bank"
    echo "  - Check if port 8080 is in use: sudo lsof -i :8080"
    echo
    
    print_color "$YELLOW" "MCP server not working:"
    echo "  - Check info: claude mcp info <server-name>"
    echo "  - Check tools: claude mcp tools <server-name>"
    echo "  - Remove and re-add: claude mcp remove <server-name>"
    echo
    
    print_color "$YELLOW" "Claude CLI not installed:"
    echo "  - Visit: https://github.com/anthropics/claude-cli"
    echo "  - Follow installation instructions for your system"
}

# Function to run complete setup
run_complete_setup() {
    print_header "Running Complete Setup"
    
    check_prerequisites
    
    if [ "$NODEJS_INSTALLED" = false ]; then
        if ask_yes_no "Install Node.js?" "y"; then
            install_nodejs
        fi
    fi
    
    if [ "$DOCKER_INSTALLED" = false ]; then
        if ask_yes_no "Install Docker?" "y"; then
            install_docker
        fi
    fi
    
    if [ "$DOCKER_INSTALLED" = true ] && [ "$DOCKER_COMPOSE_INSTALLED" = false ]; then
        if ask_yes_no "Install Docker Compose?" "y"; then
            install_docker_compose
        fi
    fi
    
    if [ "$DOCKER_INSTALLED" = true ] && [ "$MEMORY_BANK_RUNNING" = false ]; then
        if ask_yes_no "Set up Memory Bank server?" "y"; then
            setup_memory_bank
        fi
    fi
    
    if [ "$CLAUDE_CLI_INSTALLED" = true ]; then
        setup_mcp_servers
    else
        print_status "warning" "Claude CLI not installed. Skipping MCP server configuration."
        print_status "info" "Install Claude CLI from: https://github.com/anthropics/claude-cli"
    fi
    
    print_header "Setup Complete!"
    check_prerequisites
    check_mcp_servers
}

# Main script
main() {
    clear
    print_color "$CYAN" "╔════════════════════════════════════════════════════════════════╗"
    print_color "$CYAN" "║           SuperCoder MCP Setup - Interactive Installer          ║"
    print_color "$CYAN" "╚════════════════════════════════════════════════════════════════╝"
    
    # Check if running non-interactively
    if [ "${1:-}" = "--auto" ]; then
        run_complete_setup
        exit 0
    fi
    
    while true; do
        show_menu
        read -p "Select an option: " choice
        
        case $choice in
            1)
                check_prerequisites
                check_mcp_servers
                read -p "Press Enter to continue..."
                ;;
            2)
                if [ "$NODEJS_INSTALLED" = false ]; then
                    install_nodejs
                fi
                if [ "$DOCKER_INSTALLED" = false ]; then
                    install_docker
                fi
                if [ "$DOCKER_INSTALLED" = true ] && [ "$DOCKER_COMPOSE_INSTALLED" = false ]; then
                    install_docker_compose
                fi
                read -p "Press Enter to continue..."
                ;;
            3)
                setup_memory_bank
                read -p "Press Enter to continue..."
                ;;
            4)
                setup_mcp_servers
                read -p "Press Enter to continue..."
                ;;
            5)
                run_complete_setup
                read -p "Press Enter to continue..."
                ;;
            6)
                if [ "$CLAUDE_CLI_INSTALLED" = true ]; then
                    print_header "Verifying MCP Servers"
                    for server in context7 filesystem sequential-thinking fetch tavily gitmcp obsidian kg-memory memory-bank; do
                        echo
                        print_color "$CYAN" "Testing $server..."
                        claude mcp info "$server" 2>&1 | head -5 || print_status "missing" "$server not configured"
                    done
                else
                    print_status "missing" "Claude CLI not installed"
                fi
                read -p "Press Enter to continue..."
                ;;
            7)
                show_troubleshooting
                read -p "Press Enter to continue..."
                ;;
            0)
                print_color "$GREEN" "Goodbye!"
                exit 0
                ;;
            *)
                print_color "$RED" "Invalid option. Please try again."
                sleep 2
                ;;
        esac
        
        clear
    done
}

# Run main function
main "$@"