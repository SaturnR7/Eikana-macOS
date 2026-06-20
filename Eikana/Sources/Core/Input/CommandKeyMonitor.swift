//
//  CommandKeyMonitor.swift
//  Eikana
//
//  Created by Hidemasa Kobayashi on 2026/06/20.
//

import Cocoa
import Carbon

final class CommandKeyMonitor {
    // MARK: - Properties
    static let shared = CommandKeyMonitor()

    private var eventTap: CFMachPort?
    private var runLoopSource: CFRunLoopSource?
    private var commandUsedWithOtherKey = false
    private var pendingCommand: PendingCommand?
    private let commandMap: [Int64: CommandConfig] = [
        KeyCode.Physical.leftCommand.rawValue: CommandConfig(side: .left, language: .english),
        KeyCode.Physical.rightCommand.rawValue: CommandConfig(side: .right, language: .japanese)
    ]

    private struct CommandConfig {
        let side: PendingCommand
        let language: KeyCode.Language
    }

    func start() {
        guard eventTap == nil else { return }
        // グローバルで flagsChanged と keyDown を監視
        let callback: CGEventTapCallBack = { _, type, event, _ in
            let monitor = CommandKeyMonitor.shared
            switch type {
            case .keyDown:
                if monitor.pendingCommand != nil {
                    monitor.commandUsedWithOtherKey = true
                }
                return Unmanaged.passUnretained(event)
            case .flagsChanged:
                break
            default:
                return Unmanaged.passUnretained(event)
            }

            // 左右 Command キーを判定
            // flagsChanged は押下/解放の両方で来るため、押下時のみ反応させる
            // かつ単押し判定のため状態管理を行う
            //
            // flagsChanged:
            // Command / Shift / Option / Control などの修飾キーの状態変化イベント
            // 「押した瞬間」ではなく「押下・解放など状態が変わったとき」に発火する
            if let config = monitor.commandMap[event.getIntegerValueField(.keyboardEventKeycode)] {
                monitor.handleCommandEvent(
                    side: config.side,
                    isPressed: event.flags.contains(.maskCommand)
                ) {
                    InputSourceSwitcher.select(config.language)
                }
            }

            return Unmanaged.passUnretained(event)
        }

        guard let tap = CGEvent.tapCreate(tap: .cgSessionEventTap,
                                          place: .headInsertEventTap,
                                          options: .defaultTap,
                                          eventsOfInterest: CGEventMask.commandMonitor,
                                          callback: callback,
                                          userInfo: nil) else { return }
        eventTap = tap
        runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, tap, 0)
        guard let source = runLoopSource else { return }
        CFRunLoopAddSource(CFRunLoopGetCurrent(), source, .commonModes)
        CGEvent.tapEnable(tap: tap, enable: true)
    }

    func stop() {
        guard let tap = eventTap else { return }
        CGEvent.tapEnable(tap: tap, enable: false)
        if let src = runLoopSource { CFRunLoopRemoveSource(CFRunLoopGetCurrent(), src, .commonModes) }
        runLoopSource = nil
        eventTap = nil
        pendingCommand = .none
        commandUsedWithOtherKey = false
    }
}

// MARK: - Private
private extension CommandKeyMonitor {
    private func handleCommandEvent(
        side: PendingCommand,
        isPressed: Bool,
        action: () -> Void
    ) {
        if isPressed {
            pendingCommand = side
            commandUsedWithOtherKey = false
        } else {
            if pendingCommand == side,
               !commandUsedWithOtherKey {
                action()
            }
            pendingCommand = nil
        }
    }
}

// MARK: - Pending Command State
// 「どちらのCommandキーが現在操作対象か」を保持するための状態
// left: 左Commandキーが押下された状態
// right: 右Commandキーが押下された状態
// 目的は Command 単押しとショートカット操作（Cmd+Cなど）を区別するため
private extension CommandKeyMonitor {
    enum PendingCommand {
        case left
        case right
    }
}
