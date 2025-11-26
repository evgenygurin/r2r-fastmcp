---
name: cc-setup
description: Claude Code installation and setup guide
allowed-tools: Read
denied-tools: Bash, Write, Edit
---

# Claude Code Installation & Setup

Comprehensive installation documentation at @docs/claude_code/02-installation-and-setup.md

## Quick Installation

### macOS/Linux (curl):
```bash
curl -fsSL https://raw.githubusercontent.com/anthropics/claude-code/main/install.sh | sh
```

### NPM (all platforms):
```bash
npm install -g @anthropic-ai/claude-code
```

### Specific Version:
```bash
npm install -g @anthropic-ai/claude-code@1.0.58
```

## System Requirements

**Supported OS:**
- macOS 10.15+ (Intel/Apple Silicon)
- Linux (Ubuntu 20.04+, Debian 11+, Fedora 38+)
- Windows 10/11 (via WSL2)

**Requirements:**
- Node.js 18+ (for NPM installation)
- Git (recommended)
- API Key from console.anthropic.com

## Initial Setup

After installation:

1. **Authenticate:**
```bash
claude-code auth login
```

2. **Verify:**
```bash
claude-code --version
claude-code health
```

3. **Configure (optional):**
```bash
claude-code config set model claude-sonnet-4-5
```

## Instructions

1. Read the full installation documentation:
```text
Read docs/claude_code/02-installation-and-setup.md
```

2. Focus on explaining:
   - System requirements (detailed)
   - Installation methods (curl, NPM, specific versions)
   - First-time setup and authentication
   - Credential management
   - Environment variables
   - Shell integration (completion, aliases)
   - Special environments (WSL, DevContainers, CI/CD)
   - Updating and uninstalling
   - Troubleshooting installation issues

## Configuration Files

**Credentials:**
- `~/.claude/credentials` - API keys

**Settings:**
- `.claude/settings.json` - Project settings
- `~/.claude/settings.json` - Global settings

**Project Memory:**
- `CLAUDE.md` - Project context and instructions

## Environment Variables

```bash
# API Key
export ANTHROPIC_API_KEY="your-key-here"

# Model selection
export CLAUDE_MODEL="claude-sonnet-4-5"

# Proxy settings
export HTTPS_PROXY="http://proxy:8080"
```

## Shell Integration

### Bash:
```bash
echo 'eval "$(claude-code completion bash)"' >> ~/.bashrc
```

### Zsh:
```bash
echo 'eval "$(claude-code completion zsh)"' >> ~/.zshrc
```

### Fish:
```bash
claude-code completion fish > ~/.config/fish/completions/claude-code.fish
```

## WSL Setup

1. Install in WSL2 environment
2. Use Linux installation method
3. Configure Windows Terminal integration
4. Set up file paths correctly

## DevContainers Setup

Add to `.devcontainer/devcontainer.json`:
```json
{
  "features": {
    "ghcr.io/anthropics/features/claude-code:latest": {}
  }
}
```

## Updating

### NPM:
```bash
npm update -g @anthropic-ai/claude-code
```

### curl (reinstall):
```bash
curl -fsSL https://raw.githubusercontent.com/anthropics/claude-code/main/install.sh | sh
```

## Uninstalling

### NPM:
```bash
npm uninstall -g @anthropic-ai/claude-code
rm -rf ~/.claude
```

### Manual:
```bash
rm -rf /usr/local/bin/claude-code
rm -rf ~/.claude
```

## Troubleshooting

**Command not found:**
- Check PATH: `echo $PATH`
- Restart shell
- Reinstall

**Permission denied:**
- Use sudo for global install
- Or use NPM prefix: `npm config set prefix ~/.npm-global`

**Authentication failed:**
- Check API key: `cat ~/.claude/credentials`
- Re-authenticate: `claude-code auth login`

**Old version:**
- Update: `npm update -g @anthropic-ai/claude-code`
- Check: `claude-code --version`

## Next Steps

- Read full installation guide for detailed troubleshooting
- Configure project with `CLAUDE.md`
- Set up hooks in `.claude/hooks/`
- Create custom commands in `.claude/commands/`
- Use `/cc` for Claude Code quick reference
- Use `/cc-hooks`, `/cc-commands`, `/cc-mcp` for specific topics
