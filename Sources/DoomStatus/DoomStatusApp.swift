// Doom Status
// Copyright (C) 2026 Martin LeGo
//
// This program is free software; you can redistribute it and/or
// modify it under the terms of the GNU General Public License
// as published by the Free Software Foundation; either version 2
// of the License, or (at your option) any later version.
//
// Face images from DOOM, id Software.
// PNG files 1.png–6.png from https://github.com/rjzak/doom-status

import AppKit
import SwiftUI

@main
struct DoomStatusApp: App {
    @StateObject private var monitor = CPUMonitor()

    var body: some Scene {
        MenuBarExtra {
            Text(monitor.label)
            Divider()
            Button("About") {
                NSApp.activate(ignoringOtherApps: true)
                NSApp.orderFrontStandardAboutPanel(options: [
                    .credits: NSAttributedString(
                        string: "Caras de DOOM, id Software.\nPNG de rjzak/doom-status.\nCPU global, cada 5 segundos.",
                        attributes: [
                            .font: NSFont.systemFont(ofSize: NSFont.smallSystemFontSize),
                            .foregroundColor: NSColor.labelColor,
                        ]
                    ),
                ])
            }
            Button("Quit") {
                NSApplication.shared.terminate(nil)
            }
            .keyboardShortcut("q")
        } label: {
            Image(nsImage: monitor.icon)
                .id(monitor.faceIndex)
        }
        .menuBarExtraStyle(.menu)
    }
}

final class CPUMonitor: ObservableObject {
    @Published var label = "CPU …"
    @Published var icon: NSImage
    @Published var faceIndex = 1

    private var previous: CPULoad.Sample?
    private var timer: Timer?

    init() {
        icon = Face.image(forPercent: 0)
        previous = CPULoad.sample()
        let timer = Timer(timeInterval: 5, repeats: true) { [weak self] _ in
            // The timer is scheduled on the main run loop.
            DispatchQueue.main.async {
                self?.tick()
            }
        }
        RunLoop.main.add(timer, forMode: .common)
        self.timer = timer
    }

    private func tick() {
        guard let current = CPULoad.sample() else { return }
        defer { previous = current }
        guard let previous else { return }
        let percent = CPULoad.percent(from: previous, to: current)
        label = "CPU \(percent)%"
        faceIndex = Face.index(forPercent: percent)
        icon = Face.image(forPercent: percent)
    }
}

enum Face {
    /// Least hurt to most hurt: 0–16, 17–33, 34–50, 51–67, 68–84, 85–100.
    static func index(forPercent percent: Int) -> Int {
        switch percent {
        case 0...16: return 1
        case 17...33: return 2
        case 34...50: return 3
        case 51...67: return 4
        case 68...84: return 5
        default: return 6
        }
    }

    static func image(forPercent percent: Int) -> NSImage {
        let name = "\(index(forPercent: percent))"
        let loaded = Bundle.main.url(forResource: name, withExtension: "png")
            .flatMap { NSImage(contentsOf: $0) }
        let image = (loaded?.copy() as? NSImage) ?? placeholder()
        image.size = NSSize(width: 18, height: 18)
        image.isTemplate = false
        return image
    }

    private static func placeholder() -> NSImage {
        let image = NSImage(size: NSSize(width: 18, height: 18))
        image.lockFocus()
        NSColor.labelColor.setFill()
        NSBezierPath(ovalIn: NSRect(x: 2, y: 2, width: 14, height: 14)).fill()
        image.unlockFocus()
        return image
    }
}
