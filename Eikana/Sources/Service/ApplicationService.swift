//
//  ApplicationService.swift
//  Eikana
//
//  Created by Hidemasa Kobayashi on 2026/06/28.
//

import Foundation
import AppKit

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
}
