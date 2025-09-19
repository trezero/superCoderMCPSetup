# SuperCoder MCP Setup

A comprehensive interactive installer for setting up Model Context Protocol (MCP) servers with Claude Code, providing an AI-powered coding environment with enhanced capabilities.

## 🚀 Quick Start

```bash
# Clone the repository
git clone https://github.com/yourusername/superCoderMCPSetup.git
cd superCoderMCPSetup

# Make the script executable
chmod +x superCoderSetup.sh

# Run the interactive installer
./superCoderSetup.sh
```

## 📋 Prerequisites

The installer will check for and help you install:

- **Ubuntu 22.04** or compatible Linux distribution
- **Node.js LTS** (with npm and npx)
- **Docker Engine** (for self-hosted servers)
- **Docker Compose** (optional, for easier container management)
- **Claude CLI** (for MCP server registration)

## 🎯 What This Tool Does

The SuperCoder MCP Setup provides an interactive CLI that:

1. **Checks your system** for required software and shows what's installed/missing
2. **Guides installation** of prerequisites with clear instructions
3. **Configures MCP servers** with step-by-step API key setup
4. **Manages persistent storage** for configurations and server data
5. **Provides troubleshooting** help for common issues

## 🛠️ MCP Servers Included

### Core Services

| Server | Purpose | API Key Required |
|--------|---------|------------------|
| **Context7** | Version-specific documentation and API examples | Yes |
| **Filesystem** | Controlled file system access | No |
| **Sequential Thinking** | Step-by-step reasoning for complex tasks | No |
| **Fetch** | Web documentation retrieval | No |
| **Tavily** | Developer-focused web search | Yes |
| **GitMCP** | Git repository awareness and operations | No |
| **Obsidian** | Knowledge base integration | No |
| **Knowledge Graph** | Dependency and relationship mapping | No |
| **Memory Bank** | Persistent project memory across sessions | No |

## 📖 Installation Guide

### Interactive Mode (Recommended)

1. **Run the installer**:
   ```bash
   ./superCoderSetup.sh
   ```

2. **Choose from the menu**:
   - `1` - Check system status
   - `2` - Install prerequisites
   - `3` - Set up Memory Bank server
   - `4` - Configure MCP servers
   - `5` - Run complete setup
   - `6` - Verify MCP connections
   - `7` - Show troubleshooting help
   - `0` - Exit

3. **Follow the prompts** for each step

### Automated Mode

For non-interactive installation:
```bash
./superCoderSetup.sh --auto
```

This will attempt to install everything with default settings.

## 🔑 API Keys

### Context7
1. Visit [https://context7.ai](https://context7.ai)
2. Sign up for an account
3. Navigate to API settings
4. Generate a new API key

### Tavily
1. Visit [https://tavily.com](https://tavily.com)
2. Sign up for a free account
3. Go to API Keys section
4. Copy your API key

> **Note**: The installer will provide these instructions when needed and save your API keys securely in `~/.supercoder_config`

## 🗂️ Configuration

### File Locations

- **Configuration**: `~/.supercoder_config` - Stores API keys and settings
- **Memory Bank**: `~/memory-bank-mcp/` - Server repository
- **Docker Volume**: `memory-bank-data` - Persistent storage

### Customizing Paths

During setup, you can customize:
- Filesystem access paths (default: `/workspace`, `~/projects`)
- Git repository paths
- Obsidian vault location
- Knowledge Graph database location

## 🔧 Usage

### After Installation

Once installed, use Claude Code commands to interact with MCP servers:

```bash
# Check server status
claude mcp info <server-name>

# List available tools
claude mcp tools <server-name>

# Remove a server
claude mcp remove <server-name>

# Re-add a server
claude mcp add <server-name> [options]
```

### Memory Bank Management

```bash
# Check server status
docker logs memory-bank
curl http://localhost:8080

# Restart server
docker restart memory-bank

# Stop server
docker stop memory-bank
```

## 🐛 Troubleshooting

### Common Issues

#### Docker Permission Denied
```bash
# Add yourself to docker group
sudo usermod -aG docker $USER

# Activate new group (or logout/login)
newgrp docker
```

#### Memory Bank Not Responding
```bash
# Check logs
docker logs -f memory-bank

# Check if port is in use
sudo lsof -i :8080

# Restart container
docker restart memory-bank
```

#### MCP Server Not Working
```bash
# Check server info
claude mcp info <server-name>

# Remove and re-add
claude mcp remove <server-name>
# Then reconfigure through the installer
```

#### Claude CLI Not Found
Install Claude CLI from [https://github.com/anthropics/claude-cli](https://github.com/anthropics/claude-cli)

## 🏗️ Architecture

### System Overview

```
┌─────────────────────────────────────┐
│         Claude Code IDE             │
├─────────────────────────────────────┤
│          Claude CLI                 │
├─────────────────────────────────────┤
│      MCP Server Framework           │
├──────┬──────┬──────┬──────┬────────┤
│ C7   │ FS   │ Seq  │ Fetch│ ...    │
├──────┴──────┴──────┴──────┴────────┤
│    Docker (Memory Bank Server)      │
└─────────────────────────────────────┘
```

### Data Flow

1. **Claude Code** sends requests through MCP protocol
2. **MCP Servers** process requests based on their specialization
3. **Memory Bank** persists context across sessions
4. **Results** are returned to enhance Claude's capabilities

## 📚 Advanced Usage

### Environment Variables

Each MCP server can be configured with environment variables:

```bash
# Example: Reconfigure Context7 with different settings
claude mcp remove context7
claude mcp add context7 \
  -e CONTEXT7_API_KEY=your_key \
  -e CONTEXT7_TIMEOUT=30000 \
  -- npx -y @upstash/context7-mcp@latest
```

### Custom Server Configuration

Edit server configurations directly:
```bash
claude mcp edit <server-name>
```

### Multiple Projects

Use different Memory Bank namespaces for different projects:
```bash
claude mcp add memory-bank \
  -e MEMORY_BANK_URL=http://localhost:8080 \
  -e MEMORY_NAMESPACE=project-name \
  -- npx -y memory-bank-mcp@latest
```

## 🤝 Contributing

Contributions are welcome! Please:

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## 📄 License

This project is open source. See LICENSE file for details.

## 🔗 Related Projects

- [Claude CLI](https://github.com/anthropics/claude-cli)
- [MCP Specification](https://modelcontextprotocol.io)
- [Memory Bank MCP](https://github.com/alioshr/memory-bank-mcp)

## 💡 Tips

- **Start Simple**: Begin with basic servers (Filesystem, Sequential Thinking) before adding all servers
- **Test Incrementally**: Verify each server works before adding the next
- **Save API Keys**: The installer saves your API keys for future use
- **Regular Updates**: Keep servers updated with `npm update -g` for global packages

## 📞 Support

For issues or questions:
1. Check the troubleshooting section
2. Run the built-in help: `./superCoderSetup.sh` then option `7`
3. Check server-specific documentation
4. Open an issue on GitHub

---

**Happy Coding with SuperCoder MCP!** 🚀