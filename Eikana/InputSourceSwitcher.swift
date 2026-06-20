//
//  InputSourceSwitcher.swift
//  Eikana
//
//  Created by Assistant on 2026/06/20.
//

import Foundation
import Carbon

/// 入力ソースの切り替えを担当するユーティリティ
/// - 英語: com.apple.keylayout.ABC
/// - 日本語: com.apple.inputmethod.Kotoeri.Roman
enum InputSourceSwitcher {
    /// 指定の入力ソースIDに切り替える
    /// - Parameter id: TISInputSource の `kTISPropertyInputSourceID` に相当する文字列
    /// - Returns: 成功したら true
    @discardableResult
    static func selectInputSource(id: String) -> Bool {
        // 指定IDの入力ソースを検索
        let props: [CFString: Any] = [kTISPropertyInputSourceID: id]
        guard let list = TISCreateInputSourceList(props as CFDictionary, false)?.takeRetainedValue() as? [TISInputSource],
              let source = list.first else { return false }
        return TISSelectInputSource(source) == noErr
    }

    /// 英語(ABC)に切り替え
    @discardableResult
    static func selectEnglish() -> Bool {
        // ABC レイアウト
        return selectInputSource(id: "com.apple.keylayout.ABC")
    }

    /// 日本語(ことえり/ローマ字)に切り替え
    @discardableResult
    static func selectJapanese() -> Bool {
        // macOS の日本語IM（ことえり/日本語IM）
        // 新旧でIDが異なる場合があるため、順に試す
        if selectInputSource(id: "com.apple.inputmethod.Kotoeri.Roman") { return true }
        if selectInputSource(id: "com.apple.inputmethod.Kotoeri.Japanese") { return true }
        return selectInputSource(id: "com.apple.inputmethod.Japanese")
    }
}
