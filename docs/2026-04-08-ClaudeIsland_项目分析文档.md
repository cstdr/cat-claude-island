# Claude Island 项目分析文档

## 1. 项目概述

### 1.1 产品定位

**Claude Island** 是一个 macOS 菜单栏应用，为 Claude Code CLI 会话提供 Dynamic Island 风格的实时通知界面。

### 1.2 核心功能

- **Notch UI** - 从 MacBook 屏幕刘海区域展开的动画悬浮通知界面
- **实时会话监控** - 追踪多个 Claude Code 会话状态
- **权限审批** - 直接在 Notch 界面批准/拒绝工具执行请求
- **聊天历史** - 查看完整对话历史，支持 Markdown 渲染
- **自动安装** - 首次启动时自动安装 Hooks

### 1.3 系统要求

- macOS 15.6+
- Claude Code CLI

---

## 2. 技术架构

### 2.1 整体架构图

```
┌─────────────────────────────────────────────────────────────────┐
│                      ClaudeIsland App                           │
├─────────────────────────────────────────────────────────────────┤
│  ┌─────────────┐  ┌──────────────┐  ┌─────────────────────────┐ │
│  │ AppDelegate │  │ WindowManager│  │   NotchWindowController │ │
│  └─────────────┘  └──────────────┘  └─────────────────────────┘ │
├─────────────────────────────────────────────────────────────────┤
│                        UI Layer (SwiftUI)                       │
│  ┌─────────────┐  ┌──────────────┐  ┌─────────────────────────┐ │
│  │  NotchView  │  │ ClaudeInstan-│  │      ChatView           │ │
│  │             │  │ cesView      │  │                         │ │
│  └─────────────┘  └──────────────┘  └─────────────────────────┘ │
├─────────────────────────────────────────────────────────────────┤
│                      Core Layer                                  │
│  ┌──────────────────────┐  ┌──────────────────────────────────┐│
│  │   NotchViewModel      │  │   NotchActivityCoordinator       ││
│  └──────────────────────┘  └──────────────────────────────────┘│
│  ┌──────────────────────┐  ┌──────────────────────────────────┐│
│  │   NotchGeometry      │  │   ScreenSelector / SoundSelector ││
│  └──────────────────────┘  └──────────────────────────────────┘│
├─────────────────────────────────────────────────────────────────┤
│                      Services Layer                              │
│  ┌─────────────────────────────────────────────────────────────┐│
│  │              SessionStore (Actor - 状态管理中心)              ││
│  └─────────────────────────────────────────────────────────────┘│
│  ┌───────────────┐  ┌───────────────┐  ┌─────────────────────┐ │
│  │ HookSocketServer│  │ ChatHistory  │  │  ConversationParser │ │
│  │  (Unix Socket) │  │  Manager     │  │  (JSONL 解析)        │ │
│  └───────────────┘  └───────────────┘  └─────────────────────┘ │
│  ┌───────────────┐  ┌───────────────┐  ┌─────────────────────┐ │
│  │  HookInstaller │  │  TmuxController│  │  WindowFinder       │ │
│  └───────────────┘  └───────────────┘  └─────────────────────┘ │
├─────────────────────────────────────────────────────────────────┤
│                      Claude Code Hooks                            │
│  ┌─────────────────────────────────────────────────────────────┐│
│  │         claude-island-state.py (Python Hook 脚本)           ││
│  │  路径: ~/.claude/hooks/claude-island-state.py               ││
│  └─────────────────────────────────────────────────────────────┘│
└─────────────────────────────────────────────────────────────────┘
                              │
                              │ Unix Socket (/tmp/claude-island.sock)
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                      Claude Code CLI                             │
│  通过 Claude Code Hooks 发送事件:                                │
│  - UserPromptSubmit, PreToolUse, PostToolUse                    │
│  - PermissionRequest, Notification, Stop                         │
│  - SessionStart, SessionEnd, PreCompact                         │
└─────────────────────────────────────────────────────────────────┘
```

### 2.2 目录结构

```
ClaudeIsland/
├── App/
│   ├── ClaudeIslandApp.swift      # SwiftUI App 入口
│   ├── AppDelegate.swift          # NSApplicationDelegate
│   ├── WindowManager.swift        # 窗口生命周期管理
│   └── ScreenObserver.swift       # 屏幕变化监听
├── Core/
│   ├── NotchViewModel.swift       # Notch UI 状态管理 (主线程 @MainActor)
│   ├── NotchActivityCoordinator.swift # 活动状态协调
│   ├── NotchGeometry.swift        # 几何计算 (碰撞检测)
│   ├── Settings.swift             # UserDefaults 配置管理
│   ├── ScreenSelector.swift       # 屏幕选择器
│   └── SoundSelector.swift        # 声音选择器
├── Models/
│   ├── SessionState.swift         # 会话完整状态模型
│   ├── SessionEvent.swift         # 统一事件类型
│   ├── SessionPhase.swift         # 会话阶段状态机
│   ├── ChatMessage.swift          # 聊天消息模型
│   └── ToolResultData.swift       # 工具结果数据结构
├── Services/
│   ├── Hooks/
│   │   ├── HookSocketServer.swift # Unix Domain Socket 服务端
│   │   └── HookInstaller.swift   # 自动安装 Hooks
│   ├── Chat/
│   │   └── ChatHistoryManager.swift # 聊天历史管理
│   ├── Session/
│   │   ├── JSONLInterruptWatcher.swift
│   │   └── AgentFileWatcher.swift
│   ├── State/
│   │   ├── SessionStore.swift    # 核心状态管理器 (Actor)
│   │   ├── FileSyncScheduler.swift
│   │   └── ToolEventProcessor.swift
│   ├── Tmux/
│   │   ├── TmuxController.swift
│   │   ├── TmuxSessionMatcher.swift
│   │   └── ToolApprovalHandler.swift
│   ├── Window/
│   │   ├── WindowFinder.swift
│   │   ├── WindowFocuser.swift
│   │   └── YabaiController.swift
│   └── Shared/
│       ├── ProcessTreeBuilder.swift
│       ├── TerminalAppRegistry.swift
│       └── ProcessExecutor.swift
├── UI/
│   ├── Window/
│   │   ├── NotchWindow.swift      # 自定义 NSPanel (无焦点)
│   │   ├── NotchWindowController.swift
│   │   └── NotchViewController.swift
│   ├── Views/
│   │   ├── NotchView.swift        # 主 Notch SwiftUI 视图
│   │   ├── NotchHeaderView.swift
│   │   ├── NotchMenuView.swift
│   │   ├── ClaudeInstancesView.swift
│   │   ├── ChatView.swift
│   │   └── ToolResultViews.swift
│   └── Components/
│       ├── NotchShape.swift       # 自定义圆角形状
│       ├── ActionButton.swift
│       ├── ProcessingSpinner.swift
│       ├── StatusIcons.swift
│       ├── MarkdownRenderer.swift
│       ├── SoundPickerRow.swift
│       └── ScreenPickerRow.swift
├── Resources/
│   ├── claude-island-state.py    # Python Hook 脚本
│   └── ClaudeIsland.entitlements
└── Assets.xcassets/
```

---

## 3. 核心模块分析

### 3.1 通信机制：Unix Socket

**HookSocketServer** (`Services/Hooks/HookSocketServer.swift`)

- 使用 Unix Domain Socket (`/tmp/claude-island.sock`)
- 接收来自 Claude Code Hooks 的 JSON 事件
- 支持权限请求的请求/响应模式（保持 socket 开放等待用户决策）
- 包含 tool_use_id 缓存机制（因 PermissionRequest 事件不包含该字段）

**Python Hook 脚本** (`Resources/claude-island-state.py`)

- 安装到 `~/.claude/hooks/claude-island-state.py`
- 监听 Claude Code 的 hook 事件并通过 socket 发送
- 对 PermissionRequest 事件等待用户响应（最多 5 分钟超时）
- 支持的 Hook 事件：
  - `UserPromptSubmit`, `PreToolUse`, `PostToolUse`
  - `PermissionRequest`, `Notification`, `Stop`
  - `SubagentStop`, `SessionStart`, `SessionEnd`, `PreCompact`

### 3.2 状态管理：SessionStore

**SessionStore** (`Services/State/SessionStore.swift`) 是一个 Swift Actor：

- **单一事件处理入口**：`process(_ event: SessionEvent)`
- **状态发布**：`sessionsPublisher` (Combine CurrentValueSubject)
- **会话生命周期**：通过 hook 事件创建、更新、销毁会话
- **文件同步调度**：100ms 防抖的 JSONL 文件同步
- **权限状态管理**：处理批准、拒绝、socket 失败等

**SessionState** 包含：
- 基础信息：`sessionId`, `cwd`, `projectName`, `pid`, `tty`
- 状态机：`phase: SessionPhase`
- 聊天历史：`chatItems: [ChatHistoryItem]`
- 工具追踪：`toolTracker: ToolTracker`
- 子代理状态：`subagentState: SubagentState`
- 对话信息：`conversationInfo: ConversationInfo`

### 3.3 状态机：SessionPhase

```
┌─────────┐    ┌──────────────────┐    ┌────────────┐
│  idle   │◄──►│    processing    │◄──►│ compacting │
└─────────┘    └──────────────────┘    └────────────┘
     │                   │                     │
     │                   ▼                     │
     │          ┌──────────────────┐          │
     │          │ waitingForApproval│──────────┘
     │          │ (PermissionContext)│
     │          └──────────────────┘
     │                   │
     ▼                   ▼
┌─────────────┐    ┌────────────────┐
│waitingForInput│    │     ended     │
└─────────────┘    └────────────────┘
```

### 3.4 Notch UI 系统

**NotchViewModel** (`Core/NotchViewModel.swift`)

- `@Published status: NotchStatus` - `.closed`, `.opened`, `.popping`
- 几何计算：`NotchGeometry`
- 鼠标事件处理：悬停定时器（1秒自动展开）、点击关闭
- 内容切换：`.instances`, `.menu`, `.chat(SessionState)`

**NotchWindowController**

- 窗口覆盖屏幕顶部，高度 750pt
- `ignoresMouseEvents = true` 当 closed（点击穿透）
- 打开时 `ignoresMouseEvents = false`（按钮可交互）
- 启动动画：短暂展开后收缩

**NotchView** (SwiftUI)

- 使用 `NotchShape` 自定义圆角裁剪
- 状态：
  - `closed`: 仅显示刘海区域
  - `opened`: 展开面板显示内容
  - `popping`: 临时弹出状态
- 活动指示器：处理中旋转动画、权限等待图标、完成勾选图标

### 3.5 文件监听与解析

**ConversationParser** (内部服务)

- 解析 `~/.claude/projects/` 下的 JSONL 文件
- 增量解析（仅新消息）和全量解析
- 提取：消息内容、工具调用、工具结果、结构化结果

**JSONLInterruptWatcher** / **AgentFileWatcher**

- 监控 JSONL 文件变化
- 检测用户中断（`/clear` 或 Ctrl+C）

### 3.6 Tmux 支持

**TmuxController** / **TmuxSessionMatcher**

- 识别 Claude Code 是否运行在 tmux 会话中
- 通过 TTY 匹配 tmux pane 和窗口

---

## 4. 数据流

### 4.1 会话启动流程

```
1. Claude Code 启动
   ↓
2. HookInstaller 检测并安装 claude-island-state.py 到 ~/.claude/hooks/
   ↓
3. Claude Code 触发 SessionStart Hook
   ↓
4. Python 脚本通过 Unix Socket 发送 HookEvent
   ↓
5. HookSocketServer 接收并解析
   ↓
6. SessionStore.process(.hookReceived) 创建/更新 SessionState
   ↓
7. NotchViewModel 响应 UI 更新
   ↓
8. NotchView 显示活动状态
```

### 4.2 权限审批流程

```
1. Claude Code 执行工具前触发 PermissionRequest Hook
   ↓
2. Python 脚本发送等待审批事件到 Socket
   ↓
3. HookSocketServer 保持 socket 开放，缓存 tool_use_id
   ↓
4. SessionStore.process(.hookReceived) 更新 phase = .waitingForApproval
   ↓
5. NotchView 显示权限审批界面（Approve/Deny 按钮）
   ↓
6. 用户点击按钮
   ↓
7. HookSocketServer.respondToPermission() 发送决策
   ↓
8. Python 脚本接收响应，输出 JSON 决策给 Claude Code
   ↓
9. SessionStore.process(.permissionApproved/.permissionDenied) 更新状态
```

### 4.3 聊天历史更新流程

```
1. Hook 事件触发 (UserPromptSubmit, PreToolUse, PostToolUse, Stop)
   ↓
2. 调度 100ms 防抖的 FileSync
   ↓
3. ConversationParser 增量解析 JSONL 文件
   ↓
4. SessionStore.process(.fileUpdated(FileUpdatePayload))
   ↓
5. 更新 chatItems（去重、排序）
   ↓
6. 填充子代理工具信息
   ↓
7. 发布状态更新到 UI
```

---

## 5. 第三方依赖

| 依赖 | 版本 | 用途 |
|------|------|------|
| **Mixpanel** | - | 匿名使用统计 |
| **Sparkle** | - | 自动更新框架 |
| **IOKit** | 系统 | 设备 UUID 获取（Mixpanel distinct ID） |

---

## 6. 关键技术点

### 6.1 Actor 模型
`SessionStore` 使用 Swift Actor 保证线程安全，所有状态修改通过 `process(_:)` 方法进行。

### 6.2 @MainActor
`NotchViewModel` 和 `ChatHistoryManager` 使用 `@MainActor` 确保 UI 相关代码在主线程执行。

### 6.3 SwiftUI 与 AppKit 混合
- 窗口层：AppKit (`NSWindow`, `NSWindowController`, `NSPanel`)
- 内容层：SwiftUI (`some View`)
- 通信：`ObservableObject` 协议

### 6.4 Unix Socket 通信
- 高效的本地进程间通信
- 支持请求/响应模式（保持连接等待回复）
- `DispatchSource` 实现非阻塞 I/O

### 6.5 几何计算
`NotchGeometry` 处理屏幕坐标转换和点击区域判定，适配不同屏幕和刘海尺寸。

---

## 7. 附录：文件清单

| 文件 | 行数 | 职责 |
|------|------|------|
| AppDelegate.swift | ~190 | 应用生命周期、Mixinpanel 初始化、单实例检查 |
| WindowManager.swift | ~50 | 创建/管理 NotchWindowController |
| NotchWindowController.swift | ~95 | 窗口定位、事件处理配置 |
| NotchViewModel.swift | ~295 | Notch UI 状态管理 |
| NotchGeometry.swift | ~55 | 屏幕几何计算 |
| SessionStore.swift | ~990 | **核心状态管理 Actor** |
| SessionState.swift | ~345 | 会话状态数据结构 |
| SessionEvent.swift | ~220 | 统一事件类型定义 |
| HookSocketServer.swift | ~615 | Unix Socket 服务端 |
| HookInstaller.swift | ~195 | 自动安装 Hooks |
| claude-island-state.py | ~200 | Python Hook 脚本 |
| NotchView.swift | ~500 | 主 SwiftUI 视图 |
| ChatView.swift | ~300+ | 聊天历史视图 |

---

*文档生成时间: 2026-04-08*
