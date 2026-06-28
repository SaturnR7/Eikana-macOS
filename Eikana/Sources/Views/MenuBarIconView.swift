//
//  MenuBarIconView.swift
//  Eikana
//
//  Created by Hidemasa Kobayashi on 2026/06/18.
//

import SwiftUI
import AppKit
import ServiceManagement
import Combine

struct MenuBarIconView: View {
    @State private var launchAtLogin = SMAppService.mainApp.status == .enabled

    var body: some View {
        VStack {
            Button(action: toggleLaunchAtLogin) {
                Label("ログイン時に開く", systemImage: launchAtLogin ? "checkmark" : "")
            }
            Divider()
            Button("再起動") {
                restartApplication()
            }
            Divider()
            Button("終了") {
                NSApplication.shared.terminate(nil)
            }
        }
        .onAppear {
            launchAtLogin = SMAppService.mainApp.status == .enabled
        }
        .onReceive(
            Timer.publish(every: 1.0, on: .main, in: .common).autoconnect()
        ) { _ in
            launchAtLogin = (SMAppService.mainApp.status == .enabled)
        }
    }

    // MARK: - Private Method
    private func toggleLaunchAtLogin() {
        do {
            let isEnabled = (SMAppService.mainApp.status == .enabled)
            if isEnabled {
                try SMAppService.mainApp.unregister()
            } else {
                try SMAppService.mainApp.register()
            }

            launchAtLogin = (SMAppService.mainApp.status == .enabled)
        } catch {
            print("Failed to update Launch at Login: \(error)")
        }
    }

    private func restartApplication() {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/open")
        process.arguments = [Bundle.main.bundlePath]

        do {
            try process.run()
            NSApplication.shared.terminate(nil)
        } catch {
            print("Failed to restart application: \(error)")
        }
    }
}

#Preview {
    MenuBarIconView()
}
