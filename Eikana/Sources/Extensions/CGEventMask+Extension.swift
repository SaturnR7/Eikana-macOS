//
//  CGEventMask+Extension.swift
//  Eikana
//
//  Created by Hidemasa Kobayashi on 2026/06/20.
//

import Carbon

// MARK: - Event Mask
// 監視するイベントの種類を指定する
// flagsChanged: Commandキーなど修飾キーの状態変化（押下・解放）
// keyDown: 通常のキー入力（A, B, Cなど）
// これにより「キーボード入力のみ」を監視対象にしている
extension CGEventMask {
    static let commandMonitor: CGEventMask =
        (1 << CGEventType.flagsChanged.rawValue) |
        (1 << CGEventType.keyDown.rawValue)
}
