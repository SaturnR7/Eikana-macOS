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

    func start() {
        guard eventTap == nil else { return }
        // グローバルで flagsChanged と keyDown を監視
        let mask = CGEventMask.commandMonitor
        let callback: CGEventTapCallBack = { _, type, event, _ in
            let monitor = CommandKeyMonitor.shared
            if type == .keyDown {
                if monitor.pendingCommand != nil {
                    monitor.commandUsedWithOtherKey = true
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
            if keyCode == KeyCode.Physical.leftCommand.rawValue {
                monitor.handleCommandEvent(
                    side: .left,
                    isPressed: flags.contains(.maskCommand)
                ) {
                    InputSourceSwitcher.select(.english)
                }
            } else if keyCode == KeyCode.Physical.rightCommand.rawValue {
                monitor.handleCommandEvent(
                    side: .right,
                    isPressed: flags.contains(.maskCommand)
                ) {
                    InputSourceSwitcher.select(.japanese)
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
