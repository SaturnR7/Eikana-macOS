//
//  EikanaApp.swift
//  Eikana
//
//  Created by Hidemasa Kobayashi on 2026/06/18.
//

import SwiftUI
import Carbon
import Cocoa

@main
struct EikanaApp: App {
    init() {
        // アプリ起動時に左右Command監視を開始
        CommandKeyMonitor.shared.start()
    }
    var body: some Scene {
        MenuBarExtra("Eikana", systemImage: "command") {
            ContentView()
        }
    }
}
