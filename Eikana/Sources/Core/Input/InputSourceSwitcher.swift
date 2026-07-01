//
//  InputSourceSwitcher.swift
//  Eikana
//
//  Created by Hidemasa Kobayashi on 2026/06/20.
//

import Carbon
import Foundation

enum InputSourceSwitcher {
    struct InputSource: Identifiable, Hashable {
        let id: String
        let name: String
    }

    enum SwitchingMode: String, CaseIterable {
        case inputSource
        case googleJapaneseInput

        static let defaultsKey = "inputSourceSwitchingMode"

        var title: String {
            switch self {
            case .inputSource:
                "すべて（Google入力を除く）"
            case .googleJapaneseInput:
                "Google入力"
            }
        }
    }

    enum CommandSide: String {
        case left
        case right

        var defaultsKey: String {
            "commandInputSource.\(rawValue)"
        }

        var fallbackLanguage: KeyCode.Language {
            switch self {
            case .left:
                .english
            case .right:
                .japanese
            }
        }
    }

    static var switchingMode: SwitchingMode {
        get {
            guard let rawValue = UserDefaults.standard.string(forKey: SwitchingMode.defaultsKey) else {
                return .inputSource
            }

            return SwitchingMode(rawValue: rawValue) ?? .inputSource
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: SwitchingMode.defaultsKey)
        }
    }

    static var availableInputSources: [InputSource] {
        guard let sources = TISCreateInputSourceList(nil, false)?.takeRetainedValue() as? [TISInputSource] else {
            return []
        }

        let inputSources = sources.compactMap { source -> InputSource? in
            guard isSelectableKeyboardInputSource(source),
                  let id = stringProperty(source, kTISPropertyInputSourceID) else {
                return nil
            }

            let name = stringProperty(source, kTISPropertyLocalizedName) ?? id
            return InputSource(id: id, name: name)
        }

        return inputSources.sorted { $0.name.localizedStandardCompare($1.name) == .orderedAscending }
    }

    static func selectedInputSourceID(for side: CommandSide) -> String? {
        UserDefaults.standard.string(forKey: side.defaultsKey)
    }

    static func setSelectedInputSourceID(_ inputSourceID: String, for side: CommandSide) {
        UserDefaults.standard.set(inputSourceID, forKey: side.defaultsKey)
    }

    static func select(for side: CommandSide) {
        switch switchingMode {
        case .inputSource:
            selectConfiguredInputSource(for: side)
        case .googleJapaneseInput:
            sendSpecialKey(side.fallbackLanguage.rawValue)
        }
    }

    static func select(inputSourceID: String) -> Bool {
        guard let source = inputSource(with: inputSourceID) else { return false }
        return TISSelectInputSource(source) == noErr
    }
}

// MARK: - Private Method
private extension InputSourceSwitcher {
    static func selectConfiguredInputSource(for side: CommandSide) {
        if let inputSourceID = selectedInputSourceID(for: side), select(inputSourceID: inputSourceID) {
            return
        }

        sendSpecialKey(side.fallbackLanguage.rawValue)
    }

    static func inputSource(with inputSourceID: String) -> TISInputSource? {
        let properties = [kTISPropertyInputSourceID as String: inputSourceID] as CFDictionary
        guard let sources = TISCreateInputSourceList(properties, false)?.takeRetainedValue() as? [TISInputSource] else {
            return nil
        }

        return sources.first
    }

    static func isSelectableKeyboardInputSource(_ source: TISInputSource) -> Bool {
        guard let category = stringProperty(source, kTISPropertyInputSourceCategory),
              category == kTISCategoryKeyboardInputSource as String else {
            return false
        }

        return boolProperty(source, kTISPropertyInputSourceIsSelectCapable)
    }

    static func stringProperty(_ source: TISInputSource, _ key: CFString) -> String? {
        guard let pointer = TISGetInputSourceProperty(source, key) else { return nil }
        return Unmanaged<CFString>.fromOpaque(pointer).takeUnretainedValue() as String
    }

    static func boolProperty(_ source: TISInputSource, _ key: CFString) -> Bool {
        guard let pointer = TISGetInputSourceProperty(source, key) else { return false }
        return Unmanaged<CFBoolean>.fromOpaque(pointer).takeUnretainedValue() == kCFBooleanTrue
    }

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
