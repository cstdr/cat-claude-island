//
//  GhosttyController.swift
//  ClaudeIsland
//
//  Controls Ghostty terminal via AppleScript
//

import Foundation
import os.log

/// Controller for Ghostty terminal operations via AppleScript
actor GhosttyController {
    static let shared = GhosttyController()

    /// Logger
    nonisolated static let logger = Logger(subsystem: "com.claudeisland", category: "Ghostty")

    private init() {}

    // MARK: - Public API

    /// Focus the Ghostty window containing a Claude process with the given PID
    func focusWindow(forClaudePid claudePid: Int) async -> Bool {
        // Find the Ghostty window that contains this process
        guard let (windowId, terminalId) = await findGhosttyWindow(forProcess: claudePid) else {
            Self.logger.debug("Could not find Ghostty window for PID \(claudePid, privacy: .public)")
            return false
        }

        return await focusTerminal(windowId: windowId, terminalId: terminalId)
    }

    /// Send a key press to the Ghostty terminal
    func sendKey(_ key: String, modifiers: [String] = [], to claudePid: Int) async -> Bool {
        guard let (windowId, terminalId) = await findGhosttyWindow(forProcess: claudePid) else {
            return false
        }

        return await sendKeyToTerminal(key: key, modifiers: modifiers, windowId: windowId, terminalId: terminalId)
    }

    /// Send text input to the Ghostty terminal
    func sendText(_ text: String, to claudePid: Int) async -> Bool {
        guard let (windowId, terminalId) = await findGhosttyWindow(forProcess: claudePid) else {
            return false
        }

        return await inputTextToTerminal(text: text, windowId: windowId, terminalId: terminalId)
    }

    // MARK: - Private Methods

    /// Find the Ghostty window and terminal ID for a given process PID
    private func findGhosttyWindow(forProcess pid: Int) async -> (windowId: Int, terminalId: Int)? {
        // First check if the process is running in Ghostty
        let tree = ProcessTreeBuilder.shared.buildTree()

        // Walk up the process tree to find Ghostty
        var currentPid = pid
        var depth = 0
        var ghosttyPid: Int?

        while currentPid > 1 && depth < 20 {
            guard let info = tree[currentPid] else { break }

            if info.command.lowercased().contains("ghostty") {
                ghosttyPid = currentPid
                break
            }

            currentPid = info.ppid
            depth += 1
        }

        guard let targetGhosttyPid = ghosttyPid else {
            return nil
        }

        // Now find the Ghostty window with this PID using AppleScript
        let script = """
        tell application "Ghostty"
            set matchedWindow to null
            set matchedTerminal to null

            repeat with w in windows
                repeat with t in terminals of w
                    if (pid of t) = \(targetGhosttyPid) then
                        set matchedWindow to w
                        set matchedTerminal to t
                        exit repeat
                    end if
                end repeat
                if matchedWindow is not null then exit repeat
            end repeat

            if matchedWindow is null then
                return "NOT_FOUND"
            end if

            return (id of matchedWindow as string) & "|" & (id of matchedTerminal as string)
        end tell
        """

        do {
            let output = try await runAppleScript(script)
            let trimmed = output.trimmingCharacters(in: .whitespacesAndNewlines)

            if trimmed == "NOT_FOUND" || trimmed.isEmpty {
                return nil
            }

            let parts = trimmed.components(separatedBy: "|")
            guard parts.count >= 2,
                  let windowId = Int(parts[0]),
                  let terminalId = Int(parts[1]) else {
                return nil
            }

            return (windowId, terminalId)
        } catch {
            Self.logger.error("AppleScript error: \(error.localizedDescription, privacy: .public)")
            return nil
        }
    }

    /// Focus a specific terminal in Ghostty
    private func focusTerminal(windowId: Int, terminalId: Int) async -> Bool {
        let script = """
        tell application "Ghostty"
            set targetWindow to window id \(windowId)
            set targetTerminal to terminal id \(terminalId)

            set frontmost of targetWindow to true
            delay 0.05
            focus targetTerminal
        end tell
        """

        do {
            _ = try await runAppleScript(script)
            return true
        } catch {
            Self.logger.error("Failed to focus Ghostty window: \(error.localizedDescription, privacy: .public)")
            return false
        }
    }

    /// Send a key to a Ghostty terminal
    private func sendKeyToTerminal(key: String, modifiers: [String], windowId: Int, terminalId: Int) async -> Bool {
        var modList = ""
        if !modifiers.isEmpty {
            modList = modifiers.joined(separator: ",")
        }

        let script: String
        if modList.isEmpty {
            script = """
            tell application "Ghostty"
                set targetWindow to window id \(windowId)
                set targetTerminal to terminal id \(terminalId)

                focus targetTerminal
                delay 0.05
                send key "\(key)" of targetTerminal
            end tell
            """
        } else {
            script = """
            tell application "Ghostty"
                set targetWindow to window id \(windowId)
                set targetTerminal to terminal id \(terminalId)

                focus targetTerminal
                delay 0.05
                send key "\(key)" with modifiers {\(modList)} of targetTerminal
            end tell
            """
        }

        do {
            _ = try await runAppleScript(script)
            return true
        } catch {
            Self.logger.error("Failed to send key to Ghostty: \(error.localizedDescription, privacy: .public)")
            return false
        }
    }

    /// Send text input to a Ghostty terminal
    private func inputTextToTerminal(text: String, windowId: Int, terminalId: Int) async -> Bool {
        // Escape quotes in the text
        let escapedText = text.replacingOccurrences(of: "\"", with: "\\\"")

        let script = """
        tell application "Ghostty"
            set targetWindow to window id \(windowId)
            set targetTerminal to terminal id \(terminalId)

            focus targetTerminal
            delay 0.05
            input text "\(escapedText)" of targetTerminal
        end tell
        """

        do {
            _ = try await runAppleScript(script)
            return true
        } catch {
            Self.logger.error("Failed to input text to Ghostty: \(error.localizedDescription, privacy: .public)")
            return false
        }
    }

    /// Run an AppleScript command and return output
    private func runAppleScript(_ script: String) async throws -> String {
        let result = try await ProcessExecutor.shared.run(
            "/usr/bin/osascript",
            arguments: ["-e", script]
        )
        return result
    }
}
