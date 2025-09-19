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

# Or configure for a specific project
./superCoderSetup.sh --project-path /path/to/your/project
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
4. **Optimizes for specific projects** with intelligent path detection and configuration
5. **Manages persistent storage** for configurations and server data
6. **Provides troubleshooting** help for common issues

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

### Project-Specific Setup

Configure MCP servers optimized for your specific project:

```bash
# Interactive setup for a specific project
./superCoderSetup.sh --project-path /home/user/my-app

# Automated setup for a specific project
./superCoderSetup.sh -p /workspace/project --auto

# Show help and usage
./superCoderSetup.sh --help
```

#### Project Optimization Features

When using `--project-path` or `-p`, the installer automatically:

- **📁 Filesystem MCP**: Adds your project directory to allowed paths for secure file access
- **🔄 GitMCP**: Configures with your project's repository path and auto-detects the default branch
- **🧠 Knowledge Graph**: Creates a project-specific database for dependency and relationship mapping
- **💾 Memory Bank**: Uses your project name as the namespace for persistent, project-scoped memory
- **📚 Obsidian MCP**: Optionally integrates project documentation folders (`docs/`, `documentation/`, `wiki/`)

The installer validates the project path, detects if it's a Git repository, and extracts a sanitized project name for consistent naming across all MCP services.

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
- Filesystem access paths (default: `/workspace`, `~/projects`, plus project path if specified)
- Git repository paths (auto-detected for project mode)
- Obsidian vault location (can use project docs folders)
- Knowledge Graph database location (project-specific when using `--project-path`)
- Memory Bank namespace (uses project name when available)

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

#### Option 1: Use Project-Specific Setup (Recommended)
```bash
# Configure for project A
./superCoderSetup.sh --project-path /home/user/project-a --auto

# Later, reconfigure for project B
./superCoderSetup.sh --project-path /home/user/project-b --auto
```

#### Option 2: Manual Namespace Configuration
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

- **Use Project Mode**: Always use `--project-path` for better integration and project-specific configurations
- **Start Simple**: Begin with basic servers (Filesystem, Sequential Thinking) before adding all servers
- **Test Incrementally**: Verify each server works before adding the next
- **Save API Keys**: The installer saves your API keys for future use
- **Git Integration**: Ensure your project is a Git repository for optimal GitMCP functionality
- **Documentation Structure**: Organize project docs in `docs/`, `documentation/`, or `wiki/` folders for Obsidian integration
- **Regular Updates**: Keep servers updated with `npm update -g` for global packages

## 📞 Support

For issues or questions:
1. Check the troubleshooting section
2. Run the built-in help: `./superCoderSetup.sh` then option `7`
3. Check server-specific documentation
4. Open an issue on GitHub

---

**Happy Coding with SuperCoder MCP!** 🚀