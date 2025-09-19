### Archon and AI Coding Environment

### Quick install — Ubuntu 22 clean system

superCoderSetup.sh is a One-shot script to install prerequisites, self-host Memory Bank, and register all MCP servers in Claude Code.


### Claude Code: one‑line MCP server installs

For a clean machine, follow Prerequisites first, then add each MCP. Use these commands in Claude Code’s terminal. They add each server with npx so you don’t need local clones.

Prerequisites (Ubuntu 22)

- Install Node.js LTS and NPX: `sudo apt-get update && sudo apt-get install -y curl git ca-certificates && curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash - && sudo apt-get install -y nodejs`
- Verify: `node -v && npm -v && npx -v`
- Optional: Docker Engine for self-hosted servers: `curl -fsSL https://get.docker.com | sh && sudo usermod -aG docker $USER && newgrp docker && docker --version`
- Optional: Docker Compose plugin: `sudo apt-get install -y docker-compose-plugin && docker compose version`
1. **Context7 MCP**

Improves accuracy by pulling version-specific docs and examples into context so suggestions match your actual dependencies and current APIs. Reduces deprecated API usage and incorrect signatures.

Config hints: Usually needs an API key or endpoint token.

- Set: `claude mcp edit context7` → add env like `CONTEXT7_API_KEY=<key>`
- Verify: `claude mcp info context7`
    
    ```bash
    # Ubuntu 22
    claude mcp add context7 -e CONTEXT7_API_KEY=<key> -- npx -y @upstash/context7-mcp@latest
    ```
    
1. **Filesystem MCP**

Gives Claude reliable, real-time access to your files and structure to prevent broken imports, wrong paths, and duplicate files.

Config hints: Restrict root to your workspace for safety.

- Set: `claude mcp edit filesystem` → `FS_ALLOWED_PATHS=/workspace,/home/<you>/projects`
- Optional: `FS_READONLY=true` to prevent writes
    
    ```bash
    # Ubuntu 22
    claude mcp add filesystem -e FS_ALLOWED_PATHS=/workspace,/home/<you>/projects -e FS_READONLY=false -- npx -y @modelcontextprotocol/server-filesystem@latest
    ```
    
1. **Sequential Thinking MCP**

Enforces stepwise reasoning for complex tasks, improving plan quality, edge-case coverage, and implementation order.

Config hints: Usually zero-config. You can tweak max steps if exposed.

- Set: `claude mcp edit sequential-thinking` → `SEQ_MAX_STEPS=12`
    
    ```bash
    # Ubuntu 22
    claude mcp add sequential-thinking -e SEQ_MAX_STEPS=12 -- npx -y @modelcontextprotocol/server-sequential-thinking@latest
    # Windows (native, not WSL) requires cmd /c
    claude mcp add sequential-thinking -e SEQ_MAX_STEPS=12 -- cmd /c npx -y @modelcontextprotocol/server-sequential-thinking@latest
    ```
    
1. **Fetch MCP**

Fetches live web docs and converts them to usable context so Claude references current guidance, not stale snippets.

Config hints: Set timeouts and size to avoid truncation.

- Set: `claude mcp edit fetch` → `FETCH_TIMEOUT_MS=20000`, `FETCH_MAX_LENGTH=500000`
    
    ```bash
    # Ubuntu 22
    claude mcp add fetch -e FETCH_TIMEOUT_MS=20000 -e FETCH_MAX_LENGTH=500000 -- npx -y @modelcontextprotocol/server-fetch@latest
    ```
    
1. **Tavily MCP**

Adds dev-focused web search that surfaces up-to-date best practices and solutions for the exact tech stack you’re using.

Config hints: Requires Tavily API key.

- Set: `claude mcp edit tavily` → `TAVILY_API_KEY=<key>`
- Optional: `TAVILY_MAX_RESULTS=5`
    
    ```bash
    # Ubuntu 22
    claude mcp add tavily -e TAVILY_API_KEY=<key> -e TAVILY_MAX_RESULTS=5 -- npx -y @tavilyai/mcp-server@latest
    ```
    
1. **GitMCP**

Makes Claude branch- and history-aware to avoid conflicts and suggestions that ignore recent commits or repo conventions.

Config hints: Point to repo root and set safe operations.

- Set: `claude mcp edit gitmcp` → `GIT_REPO_PATH=/workspace/<repo>`, `GIT_DEFAULT_BRANCH=main`
- Optional: `GIT_ALLOW_WRITE=true`
    
    ```bash
    # Ubuntu 22
    claude mcp add gitmcp -e GIT_REPO_PATH=/workspace/<repo> -e GIT_DEFAULT_BRANCH=main -e GIT_ALLOW_WRITE=false -- npx -y gitmcp@latest
    ```
    
1. **Obsidian MCP**

Brings your vault’s notes and decisions into the IDE so code aligns with documented requirements and architecture.

Config hints: Provide vault path and optionally read-only.

- Set: `claude mcp edit obsidian` → `OBSIDIAN_VAULT_PATH=/home/<you>/Obsidian/<vault>`, `OBSIDIAN_READONLY=true`
    
    ```bash
    # Ubuntu 22
    claude mcp add obsidian -e OBSIDIAN_VAULT_PATH=/home/<you>/Obsidian/<vault> -e OBSIDIAN_READONLY=true -- npx -y mcp-obsidian@latest
    ```
    
1. **Knowledge Graph Memory MCP**

Maps relationships across modules to prevent cascade breakages and guide safe refactors with dependency awareness.

Config hints: Choose storage location and capacity.

- Set: `claude mcp edit kg-memory` → `KG_DB_PATH=/workspace/.kgmcp/db.sqlite`, `KG_MAX_NODES=50000`
    
    ```bash
    # Ubuntu 22
    claude mcp add kg-memory -e KG_DB_PATH=/workspace/.kgmcp/db.sqlite -e KG_MAX_NODES=50000 -- npx -y mcp-knowledge-graph@latest
    ```
    
1. **Memory Bank MCP**

Creates persistent project memory so Claude retains prior choices, standards, and context across sessions.

Config hints: Point to memory store and scope per project.

Install and self-host (Ubuntu 22, Docker)

```bash
# Ensure Docker and Git are available (see Prerequisites above for Docker install)
sudo apt-get update && sudo apt-get install -y git

# Clone the server repo
cd ~ && git clone https://github.com/alioshr/memory-bank-mcp.git
cd memory-bank-mcp

# Start the server
if command -v docker >/dev/null 2>&1 && docker compose version >/dev/null 2>&1; then
  # Option A: Docker Compose (preferred if available)
  docker compose up -d
else
  # Option B: Build and run with Docker
  sudo docker build -t memory-bank-mcp .
  sudo docker run -d \
    --name memory-bank \
    -p 8080:8080 \
    -e MEMORY_BANK_STORAGE_DIR=/data \
    -v memory-bank-data:/data \
    memory-bank-mcp
fi

# Health check (may take a few seconds to become ready)
sleep 3
curl -sfS http://localhost:8080 || echo "Warning: Memory Bank may still be starting"
```

Connect from Claude Code

```bash
# Ubuntu 22
claude mcp add memory-bank \
  -e MEMORY_BANK_URL=http://localhost:8080 \
  -e MEMORY_NAMESPACE=<project> \
  -- npx -y memory-bank-mcp@latest
```

Post-install

- Verify: `claude mcp info memory-bank` and `claude mcp tools memory-bank`
- Logs: `docker logs -f memory-bank` or `docker compose logs -f`
- Persistence: Data stored in Docker volume `memory-bank-data`

Notes

- Use `-e ENV_VAR=value` for each environment variable. Add multiple `-e` flags as needed.
- On native Windows (not WSL), wrap NPX servers with `cmd /c`.
- `--` separates Claude options from the server command and its arguments.
- To remove a server: `claude mcp remove <name>`; to test tools: `claude mcp tools <name>`

---

### Prepare an Existing Repo for Archon

1. Connect to Archon via Claude MCP:
    
    ```bash
    claude mcp add --transport http archon http://localhost:http://localhost:8051/mcp
    ```
    
2. Install BMAD Method:
    
    ```bash
    npx bmad-method install
    ```
    
    - Provide the absolute path to the current project
    - Choose "BMad Agile Core System"
    - Shard PRD: Yes
    - Shard Architecture docs: Yes
    - IDE: usually Claude Code
    - Prebuilt web bundles: No
3. Install Gemini CLI and connect to Archon:
    
    ```bash
    npm install -g @google/gemini-cli
    # Install Gemini CLI companion plugin in VS Code
    gemini mcp add --transport http archon http://localhost:http://localhost:8051/mcp
    ```
    
    - Start Gemini. First slash command may take time to load.
    - Continue prior work: `/BMad:agents:dev`
4. Add Gemini MCP Servers:
    - Sequential Thinking:
        
        ```bash
        gemini mcp add sequential-thinking "npx -y @modelcontextprotocol/server-sequential-thinking"
        ```
        
    - Puppeteer:
        
        ```bash
        gemini mcp add puppeteer "npx -y @modelcontextprotocol/server-puppeteer"
        ```
        

---

### Authenticated Crawling Issue

Target site: https://perifery.atlassian.net/wiki/spaces/AI/pages/3662938115/AI+Architecture requires login but no prompt appears. Only the initial login page is visible.

Goal: Enable crawling using the new authentication process to retrieve an API key, identify the API, and access the requested page using the API key.

Options:

- Implement new auth flow and use API.
- Find or specify an MCP server that supports this site's auth.
- If needed, propose new stories or an epic.

---

### Alternatives

1. Install Codebuff for a comparable agent
    - Notes: TBD
2. Additional options: TBD

---

### Docs

- BMad Brownfield Method: https://github.com/bmad-code-org/BMAD-METHOD/blob/bfaaa0ee117ec858a3160b1601745c8acac17cc0/bmad-core/working-in-the-brownfield.md
- BMAD Workflow diagram: https://github.com/bmad-code-org/BMAD-METHOD/blob/main/docs/user-guide.md

---

### Prompt to ChatGPT

You are an expert AI coding prompt engineer. Help me improve these prompts to my coding agent. Do not provide code. Provide a high quality, succinct prompt to my coding agent to accomplish the task. Only provide the prompt if you are over 90% confident it will achieve the desired result; otherwise, ask for the additional information needed to reach over 90% confidence.

---

### Making Small Changes to a Project

1. Load the analyst agent: `/analyst` (finds the BMad Analyst)
2. `*document-project`
    - Note: This command may not be available directly
3. Load the PM agent
4. Task example: Fix sorting on the Media Library page by newest, oldest, or filename.
    - First, fully document the project to build context.

---

### Business Analyst Agent (Mary)

- Message: "document-project" is a task in dependencies, not a direct command. Mary can run it directly.
- Question: Should Mary run the "document-project" task now?

---

### Videos and Setup Guides

- The Official BMad-Method Masterclass (The Complete IDE Workflow): https://www.youtube.com/watch?v=LorEJPrALcg
- Introducing Archon — The Revolutionary OS for AI Coding: https://www.youtube.com/watch?v=8pRc_s2VQIo
- Archon Beta Launch Livestream — What You Missed!: https://www.youtube.com/watch?v=yAFzPzpzJHU

---

### Archon Workflow Requests

- Use Archon to research the Claude Code SDK and add technical implementation ideas to the project brief.
- Save the brief in a new Archon project.

---

### PM and Architect Collaboration

- PM agent:
    - Generate a PRD based on the Spec documents in Archon.
    - Also research Claude Code SDK and add implementation ideas, then save the brief in a new Archon project.
- Architect agent:
    - Use the existing project "Claude Code Management Dashboard" in Archon.
    - Read the PRD.
    - Break the PRD into no more than 20 tasks and add them to the project's Tasks section.

---

### Development Flow

- Switch to PRP for development
- Grab the PRP template from the context-engineering-intro GitHub repository