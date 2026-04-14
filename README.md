# Pet Claude Island

<div align="center">
  <img src="ClaudeIsland/Assets.xcassets/AppIcon.appiconset/icon_128x128.png" alt="Logo" width="100" height="100">
  <h3 align="center">Pet Claude Island</h3>
  <p align="center">
    A macOS menu bar app featuring adorable animated cats in the Dynamic Island.
    <br />
    Track Claude Code sessions with pixel-art cat companions 🐱
    <br />
    <a href="README_zh.md">中文版</a>
    <br />
    <br />
    <a href="https://github.com/cstdr/pet-claude-island/releases/latest" target="_blank" rel="noopener noreferrer">
      <img src="https://img.shields.io/github/v/release/cstdr/pet-claude-island?style=rounded&color=white&labelColor=000000&label=release" alt="Release Version" />
    </a>
    <a href="https://github.com/cstdr/pet-claude-island" target="_blank" rel="noopener noreferrer">
      <img alt="GitHub" src="https://img.shields.io/github/downloads/cstdr/pet-claude-island/total?style=rounded&color=white&labelColor=000000">
    </a>
  </p>
</div>

## Features

- **Animated Cat Icons** — Pixel-art cats (Gulu & Yiyi) animate in the menu bar notch
  - Idle: sleeping cat with breathing animation
  - Waiting: sitting cat with wagging tail
  - Processing: running cat with white triangle face and pink nose
  - Approval: cat with raised paw
- **Notch UI** — Animated overlay that expands from the MacBook notch
- **Live Session Monitoring** — Track multiple Claude Code sessions in real-time
- **Permission Approvals** — Approve or deny tool executions directly from the notch
- **Chat History** — View full conversation history with markdown rendering
- **Auto-Setup** — Hooks install automatically on first launch

## Requirements

- macOS 15.6+
- Claude Code CLI

## Install

Download the latest release or build from source:

```bash
xcodebuild -scheme PetClaudeIsland -configuration Release build
```

## How It Works

Pet Claude Island installs hooks into `~/.claude/hooks/` that communicate session state via a Unix socket. The app listens for events and displays them in the notch overlay.

When Claude needs permission to run a tool, the notch expands with approve/deny buttons—no need to switch to the terminal.

## Analytics

Pet Claude Island uses Mixpanel to collect anonymous usage data:

- **App Launched** — App version, build number, macOS version
- **Session Started** — When a new Claude Code session is detected

No personal data or conversation content is collected.

## License

Apache 2.0

Based on [Claude Island](https://github.com/farouqaldori/claude-island) by Farouq Aldori.
