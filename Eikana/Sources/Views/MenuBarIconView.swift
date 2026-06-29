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
    @State private var switchingMode = InputSourceSwitcher.switchingMode
    @State private var inputSources = InputSourceSwitcher.availableInputSources
    @State private var selectedLeftInputSourceID = InputSourceSwitcher.selectedInputSourceID(for: .left)
    @State private var selectedRightInputSourceID = InputSourceSwitcher.selectedInputSourceID(for: .right)

    var body: some View {
        VStack {
            Menu("切り替え方式") {
                switchingModeButtons()
            }
            Divider()
            Menu("左Command") {
                inputSourceButtons(for: .left, selectedID: selectedLeftInputSourceID)
            }
            Menu("右Command") {
                inputSourceButtons(for: .right, selectedID: selectedRightInputSourceID)
            }
            Divider()
            Button(action: {
                applicationService.toggleLoginItem()
            }) {
                HStack {
                    if launchAtLogin { Image(systemName: "checkmark") }
                    Text("ログイン時に開く")
                }
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
        .onAppear {
            refreshInputSourceState()
        }
        .onReceive(
            Timer.publish(every: 1.0, on: .main, in: .common).autoconnect()
        ) { _ in
            launchAtLogin = (applicationService.isLoginItemEnabled())
            refreshInputSourceState()
        }
    }
}

// MARK: - Private Method
private extension MenuBarIconView {
    @ViewBuilder
    func switchingModeButtons() -> some View {
        ForEach(InputSourceSwitcher.SwitchingMode.allCases, id: \.self) { mode in
            Button(action: {
                InputSourceSwitcher.switchingMode = mode
                refreshInputSourceState()
            }) {
                HStack {
                    if switchingMode == mode { Image(systemName: "checkmark") }
                    Text(mode.title)
                }
            }
        }
    }

    @ViewBuilder
    func inputSourceButtons(
        for side: InputSourceSwitcher.CommandSide,
        selectedID: String?
    ) -> some View {
        if inputSources.isEmpty {
            Text("入力ソースがありません")
        } else {
            ForEach(inputSources) { inputSource in
                Button(action: {
                    InputSourceSwitcher.setSelectedInputSourceID(inputSource.id, for: side)
                    refreshInputSourceState()
                }) {
                    HStack {
                        if selectedID == inputSource.id { Image(systemName: "checkmark") }
                        Text(inputSource.name)
                    }
                }
            }
        }
    }

    func refreshInputSourceState() {
        switchingMode = InputSourceSwitcher.switchingMode
        inputSources = InputSourceSwitcher.availableInputSources
        selectedLeftInputSourceID = InputSourceSwitcher.selectedInputSourceID(for: .left)
        selectedRightInputSourceID = InputSourceSwitcher.selectedInputSourceID(for: .right)
    }
}

#Preview {
    let applicationService = ApplicationService()
    MenuBarIconView().environment(applicationService)
}
