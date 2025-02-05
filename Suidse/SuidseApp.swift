//
//  SuidseApp.swift
//  Suidse
//
//  Created by James Edmond on 2/2/25.
//

import SwiftUI


class AppDelegate: NSObject, NSApplicationDelegate {
    func application(_ application: NSApplication, open urls: [URL]) {
        FileHandler.shared.handleUrls(urls)
        NSApp.activate(ignoringOtherApps: true)
    }
}

@main
struct SuidseApp: App {
    @StateObject private var fileHandler = FileHandler.shared
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    
    var body: some Scene {
        // Settings WindowGroup
        WindowGroup("Settings") {
            SettingsView(isConversionContext: false)
                .frame(width: 350, height: 300)
                .environmentObject(fileHandler)
        }
        .windowResizability(.contentSize)
        .defaultSize(width: 350, height: 300)
        .handlesExternalEvents(matching: [])
        
        // Single Conversion Window
        Window("Conversion", id: "conversionWindow") {
            SettingsView(isConversionContext: true)
                .frame(width: 350, height: 325)
                .environmentObject(fileHandler)
        }
        .windowResizability(.contentSize)
        .defaultSize(width: 350, height: 325)
        .handlesExternalEvents(matching: Set(arrayLiteral: "*"))
    }
}


class FileHandler: ObservableObject {
    static let shared = FileHandler()
    
    @Published var inputUrls: [URL] = []
    
    func handleUrls(_ urls: [URL]) {
        self.inputUrls = urls.filter { url in
            let ext = url.pathExtension.lowercased()
            guard FileManager.default.isReadableFile(atPath: url.path) else {
                return false
            }
            return ["jpg", "jpeg", "png", "heic", "webp", "tiff", "bmp", "gif"].contains(ext)
        }
    }
}

#Preview {
    SettingsView(isConversionContext: true)
        .environmentObject(FileHandler())
}
