//
//  EikanaApp.swift
//  Eikana
//
//  Created by Hidemasa Kobayashi on 2026/06/18.
//

import SwiftUI

@main
struct EikanaApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @State private var applicationService = ApplicationService()

    var body: some Scene {
        #if DEBUG
        MenuBarExtra("Eikana", image: "ic-command-debug") {
            MenuBarIconView()
                .environment(applicationService)
        }
        #else
        MenuBarExtra("Eikana", image: "ic-command") {
            MenuBarIconView()
                .environment(applicationService)
        }
        #endif
    }
}
