//
//  InputSourceSwitcher.swift
//  Eikana
//
//  Created by Hidemasa Kobayashi on 2026/06/20.
//

import Carbon

enum InputSourceSwitcher {

    static func select(_ language: KeyCode.Language) {
        switch language {
        case .english:
            sendSpecialKey(language.rawValue)
        case .japanese:
            sendSpecialKey(language.rawValue)
        }
    }
}

// MARK: - Private Method
private extension InputSourceSwitcher {
    static func sendSpecialKey(_ keyCode: CGKeyCode) {
        guard let source = CGEventSource(stateID: .hidSystemState) else { return }

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
}
