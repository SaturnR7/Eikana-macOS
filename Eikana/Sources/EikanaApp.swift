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
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    var body: some Scene {
        MenuBarExtra("Eikana", systemImage: "command") {
            MenuBarIconView()
        }
    }
}
