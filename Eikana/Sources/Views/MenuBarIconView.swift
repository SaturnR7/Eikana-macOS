//
//  MenuBarIconView.swift
//  Eikana
//
//  Created by Hidemasa Kobayashi on 2026/06/18.
//

import Combine
import ServiceManagement
import SwiftUI

struct MenuBarIconView: View {
    @Environment(ApplicationService.self) private var applicationService
    @State private var launchAtLogin = SMAppService.mainApp.status == .enabled

    var body: some View {
        VStack {
            Button(action: {
                applicationService.toggleLoginItem()
            }) {
                Label("ログイン時に開く", systemImage: launchAtLogin ? "checkmark" : "")
            }
            Divider()
            Button("再起動") {
                applicationService.restart()
            }
            Divider()
            Button("終了") {
                NSApplication.shared.terminate(nil)
            }
        }
        .onReceive(
            Timer.publish(every: 1.0, on: .main, in: .common).autoconnect()
        ) { _ in
            launchAtLogin = (applicationService.isLoginItemEnabled())
        }
    }
}

#Preview {
    MenuBarIconView()
}
