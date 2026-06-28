//
//  CommandKeyMonitor.swift
//  Eikana
//
//  Created by Hidemasa Kobayashi on 2026/06/20.
//

import Carbon

final class CommandKeyMonitor {
    // MARK: - Properties
    private var eventTap: CFMachPort?
    private var runLoopSource: CFRunLoopSource?
    private var commandUsedWithOtherKey = false
    private var pendingCommand: PendingCommand?
    private let commandMap: [Int64: KeyConfig] = [
        KeyCode.Physical.leftCommand.rawValue: KeyConfig(side: .left, commandSide: .left),
        KeyCode.Physical.rightCommand.rawValue: KeyConfig(side: .right, commandSide: .right)
    ]

    func start() {
        guard eventTap == nil else { return }

        let callback: CGEventTapCallBack = { _, type, event, refcon in
            guard let refcon else { return Unmanaged.passUnretained(event) }
            let monitor = Unmanaged<CommandKeyMonitor>.fromOpaque(refcon).takeUnretainedValue()

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

            if let config = monitor.commandMap[event.getIntegerValueField(.keyboardEventKeycode)] {
                monitor.handleCommandEvent(
                    side: config.side,
                    isPressed: event.flags.contains(.maskCommand)
                ) {
                    InputSourceSwitcher.select(for: config.commandSide)
                }
            }

            return Unmanaged.passUnretained(event)
        }

        let selfPtr = Unmanaged.passUnretained(self).toOpaque()
        guard let tap = CGEvent.tapCreate(tap: .cgSessionEventTap,
                                          place: .headInsertEventTap,
                                          options: .defaultTap,
                                          eventsOfInterest: CGEventMask.commandMonitor,
                                          callback: callback,
                                          userInfo: selfPtr) else { return }
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
        pendingCommand = nil
        commandUsedWithOtherKey = false
    }
}

// MARK: - Private Method
private extension CommandKeyMonitor {
    func handleCommandEvent(
        side: PendingCommand,
        isPressed: Bool,
        action: () -> Void
    ) {
        if isPressed {
            pendingCommand = side
            commandUsedWithOtherKey = false
            return
        }
        guard pendingCommand == side, !commandUsedWithOtherKey else { return }
        defer { pendingCommand = nil }
        action()
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

// MARK: - Key Config
private extension CommandKeyMonitor {
    struct KeyConfig {
        let side: PendingCommand
        let commandSide: InputSourceSwitcher.CommandSide
    }
}
