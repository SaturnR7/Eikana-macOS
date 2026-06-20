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

    static func selectEnglish() {
        sendSpecialKey(0x66)
    }

    static func selectJapanese() {
        sendSpecialKey(0x68)
    }
}
