//
//  InputSourceSwitcher.swift
//  Eikana
//
//  Created by Assistant on 2026/06/20.
//

import Foundation
import Carbon

enum InputSourceSwitcher {
    private static func sendSpecialKey(_ keyCode: CGKeyCode) {
        guard let source = CGEventSource(stateID: .hidSystemState) else {
            return
        }

        let keyDown = CGEvent(
            keyboardEventSource: source,
            virtualKey: keyCode,
            keyDown: true
        )

        let keyUp = CGEvent(
            keyboardEventSource: source,
            virtualKey: keyCode,
            keyDown: false
        )

        keyDown?.post(tap: .cgSessionEventTap)
        keyUp?.post(tap: .cgSessionEventTap)
    }

    @discardableResult
    static func selectEnglish() -> Bool {
        sendSpecialKey(0x66)
        return true
    }

    @discardableResult
    static func selectJapanese() -> Bool {
        sendSpecialKey(0x68)
        return true
    }
}
