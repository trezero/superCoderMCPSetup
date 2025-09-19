# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This repository contains setup scripts and documentation for establishing a comprehensive MCP (Model Context Protocol) server environment for AI-powered coding assistance, particularly optimized for Claude Code with various specialized servers.

## Key Scripts and Commands

### Initial Setup
```bash
# Run the interactive setup (Ubuntu 22)
./superCoderSetup.sh

# Run non-interactive auto setup
./superCoderSetup.sh --auto

# Configure for a specific project
./superCoderSetup.sh --project-path /path/to/your/project

# Configure for a specific project with auto setup
./superCoderSetup.sh -p /path/to/your/project --auto

# The script provides:
# - Interactive menu system with status checking
# - Guided installation for missing components
# - API key configuration with instructions
# - Project-specific MCP server configuration
# - Troubleshooting help
```

### Project-Specific Configuration

When using the `--project-path` or `-p` option, the script will automatically configure MCP servers optimized for your specific project:

**Filesystem MCP**: Adds your project directory to allowed paths for secure file access
**GitMCP**: Automatically configures with your project's repository path and detects the default branch
**Knowledge Graph Memory**: Creates a project-specific database for dependency mapping
**Memory Bank**: Uses your project name as the namespace for persistent memory
**Obsidian MCP**: Optionally uses project documentation folders (docs/, documentation/, wiki/)

### MCP Server Management
```bash
# Verify MCP server status
claude mcp info <server-name>
claude mcp tools <server-name>

# Remove a server
claude mcp remove <server-name>

# Available servers: context7, filesystem, sequential-thinking, fetch, tavily, gitmcp, obsidian, kg-memory, memory-bank
```

### Memory Bank Management
```bash
# Check Memory Bank status (if self-hosted)
docker logs -f memory-bank
curl -sfS http://localhost:8080

# Restart Memory Bank
docker restart memory-bank
```

## Architecture

### MCP Server Ecosystem
The system integrates multiple specialized MCP servers:

1. **Context7**: Version-specific documentation and API examples
2. **Filesystem**: Direct file system access with safety boundaries
3. **Sequential Thinking**: Step-by-step reasoning for complex tasks
4. **Fetch**: Web documentation retrieval
5. **Tavily**: Developer-focused web search
6. **GitMCP**: Git repository awareness
7. **Obsidian**: Knowledge base integration
8. **Knowledge Graph Memory**: Dependency and relationship mapping
9. **Memory Bank**: Persistent project memory across sessions

### Configuration Requirements
- **API Keys Required**: Context7 (`CONTEXT7_API_KEY`), Tavily (`TAVILY_API_KEY`)
- **Path Configurations**: Filesystem paths, Git repo paths, Obsidian vault paths
- **Docker**: Required for self-hosted Memory Bank server

### Integration with Other Tools
The setup is designed to work with:
- Archon (via HTTP MCP connection at `http://localhost:8051/mcp`)
- BMAD Method for brownfield project management
- Gemini CLI for additional AI assistance

## Development Workflow

When working on MCP server configurations:
1. Edit environment variables in the setup script or use `claude mcp edit <server-name>`
2. Test server connectivity with `claude mcp tools <server-name>`
3. For Memory Bank persistence, data is stored in Docker volume `memory-bank-data`