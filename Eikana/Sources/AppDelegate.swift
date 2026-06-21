//
//  AppDelegate.swift
//  Eikana
//
//  Created by Hidemasa Kobayashi on 2026/06/20.
//

import Cocoa

final class AppDelegate: NSObject, NSApplicationDelegate {
    private let commandKeyMonitor = CommandKeyMonitor()

    func applicationDidFinishLaunching(_ notification: Notification) {
        commandKeyMonitor.start()
    }

    func applicationWillTerminate(_ notification: Notification) {
        commandKeyMonitor.stop()
    }
}
