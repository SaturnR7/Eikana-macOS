//
//  MenuBarIconView.swift
//  Eikana
//
//  Created by Hidemasa Kobayashi on 2026/06/18.
//

import SwiftUI
import AppKit
import ServiceManagement

struct MenuBarIconView: View {
    @State private var launchAtLogin = SMAppService.mainApp.status == .enabled

    var body: some View {
        VStack {
            Button(action: toggleLaunchAtLogin) {
                Label("ログイン時に開く", systemImage: launchAtLogin ? "checkmark" : "")
            }
            Divider()
            Button("終了") {
                NSApplication.shared.terminate(nil)
            }
        }
    }

    // MARK: - Private Method
    private func toggleLaunchAtLogin() {
        do {
            if launchAtLogin {
                try SMAppService.mainApp.unregister()
            } else {
                try SMAppService.mainApp.register()
            }

            launchAtLogin = (SMAppService.mainApp.status == .enabled)
        } catch {
            print("Failed to update Launch at Login: \(error)")
        }
    }
}

#Preview {
    MenuBarIconView()
}
