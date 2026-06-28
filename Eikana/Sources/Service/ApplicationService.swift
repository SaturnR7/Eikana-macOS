//
//  ApplicationService.swift
//  Eikana
//
//  Created by Hidemasa Kobayashi on 2026/06/28.
//

import AppKit
import ServiceManagement

@Observable
final class ApplicationService {

    // Restart
    func restart() {
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

    // App Login Item
    func toggleLoginItem() {
        if SMAppService.mainApp.status == .enabled {
            try? SMAppService.mainApp.unregister()
        } else {
            try? SMAppService.mainApp.register()
        }
    }

    // Check Login Item Status
    func isLoginItemEnabled() -> Bool {
        SMAppService.mainApp.status == .enabled
    }
}
