//
//  CommandKeyMonitor.swift
//  Eikana
//
//  Created by Assistant on 2026/06/20.
//

import Cocoa
import Carbon

/// 左右のCommandキー単押しを検出して入力ソースを切り替える
/// - 左Command: 英語
/// - 右Command: 日本語
final class CommandKeyMonitor {
    static let shared = CommandKeyMonitor()

    private var eventTap: CFMachPort?
    private var runLoopSource: CFRunLoopSource?

    private init() {}

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
            pendingCommand = .none
        }
    }

    private enum KeyCode {
        static let leftCommand: Int64 = 0x37
        static let rightCommand: Int64 = 0x36
    }

    private enum PendingCommand {
        case none
        case left
        case right
    }

    private var pendingCommand: PendingCommand = .none
    private var commandUsedWithOtherKey = false

    /// 監視開始
    func start() {
        guard eventTap == nil else { return }
        // グローバルで flagsChanged と keyDown を監視
        let mask = CGEventMask(
            (1 << CGEventType.flagsChanged.rawValue) |
            (1 << CGEventType.keyDown.rawValue)
        )
        let callback: CGEventTapCallBack = { _, type, event, _ in
            if type == .keyDown {
                if CommandKeyMonitor.shared.pendingCommand != .none {
                    CommandKeyMonitor.shared.commandUsedWithOtherKey = true
                }
                return Unmanaged.passUnretained(event)
            }

            guard type == .flagsChanged else {
                return Unmanaged.passUnretained(event)
            }

            // 左右Commandの押下/離脱を検出
            let flags = event.flags
            let keyCode = event.getIntegerValueField(.keyboardEventKeycode)

            // Commandキーの物理左右を判定（左: 0x37, 右: 0x36）
            // flagsChangedは押下/解放の両方で来るため、押下時のみ反応させる
            // かつ単押し判定のため状態管理を行う
            if keyCode == KeyCode.leftCommand {
                CommandKeyMonitor.shared.handleCommandEvent(
                    side: .left,
                    isPressed: flags.contains(.maskCommand)
                ) {
                    InputSourceSwitcher.selectEnglish()
                }
            } else if keyCode == KeyCode.rightCommand {
                CommandKeyMonitor.shared.handleCommandEvent(
                    side: .right,
                    isPressed: flags.contains(.maskCommand)
                ) {
                    InputSourceSwitcher.selectJapanese()
                }
            }

            return Unmanaged.passUnretained(event)
        }

        guard let tap = CGEvent.tapCreate(tap: .cgSessionEventTap,
                                          place: .headInsertEventTap,
                                          options: .defaultTap,
                                          eventsOfInterest: mask,
                                          callback: callback,
                                          userInfo: nil) else { return }
        eventTap = tap
        runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, tap, 0)
        guard let source = runLoopSource else { return }
        CFRunLoopAddSource(CFRunLoopGetCurrent(), source, .commonModes)
        CGEvent.tapEnable(tap: tap, enable: true)
    }

    /// 監視停止
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
