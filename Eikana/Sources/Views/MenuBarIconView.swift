//
//  MenuBarIconView.swift
//  Eikana
//
//  Created by Hidemasa Kobayashi on 2026/06/18.
//

import SwiftUI
import AppKit

struct MenuBarIconView: View {
    var body: some View {
        VStack {
            Text("ログイン時に開く")
            Divider()
            Button("終了") {
                NSApplication.shared.terminate(nil)
            }
        }
    }
}

#Preview {
    MenuBarIconView()
}
