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
    
    // どちらかのCommandキーが押されているかの状態管理
    private var leftCmdPressed: Bool = false
    private var rightCmdPressed: Bool = false

    private init() {}

    /// 監視開始
    func start() {
        guard eventTap == nil else { return }
        // グローバルで flagsChanged を監視
        let mask = CGEventMask(1 << CGEventType.flagsChanged.rawValue)
        let callback: CGEventTapCallBack = { _, type, event, _ in
            guard type == .flagsChanged else { return Unmanaged.passUnretained(event) }

            // 左右Commandの押下/離脱を検出
            let flags = event.flags
            let keyCode = event.getIntegerValueField(.keyboardEventKeycode)

            // Commandキーの物理左右を判定（左: 0x37, 右: 0x36）
            // flagsChangedは押下/解放の両方で来るため、押下時のみ反応させる
            // かつ単押し判定のため状態管理を行う
            if keyCode == 0x37 {
                if flags.contains(.maskCommand) {
                    // 左Command押下
                    if !CommandKeyMonitor.shared.leftCmdPressed && !CommandKeyMonitor.shared.rightCmdPressed {
                        _ = InputSourceSwitcher.selectEnglish()
                    }
                    CommandKeyMonitor.shared.leftCmdPressed = true
                } else {
                    // 左Command離脱
                    CommandKeyMonitor.shared.leftCmdPressed = false
                }
            } else if keyCode == 0x36 {
                if flags.contains(.maskCommand) {
                    // 右Command押下
                    if !CommandKeyMonitor.shared.rightCmdPressed && !CommandKeyMonitor.shared.leftCmdPressed {
                        _ = InputSourceSwitcher.selectJapanese()
                    }
                    CommandKeyMonitor.shared.rightCmdPressed = true
                } else {
                    // 右Command離脱
                    CommandKeyMonitor.shared.rightCmdPressed = false
                }
            }
            print("test keyCode: \(keyCode)")

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
        leftCmdPressed = false
        rightCmdPressed = false
    }
}

