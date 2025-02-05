//
//  SuidseApp.swift
//  Suidse
//
//  Created by James Edmond on 2/2/25.
//

import SwiftUI


class AppDelegate: NSObject, NSApplicationDelegate {
    static let shared = AppDelegate()
    private var fileHandler: FileHandler?
    
    func application(_ application: NSApplication, open urls: [URL]) {
        guard let fileHandler = fileHandler else {
            print("FileHandler not initialized")
            return
        }
        fileHandler.handleUrls(urls)
        NSApp.activate(ignoringOtherApps: true)
    }
    
    func setFileHandler(_ handler: FileHandler) {
        fileHandler = handler
    }
}

@main
struct SuidseApp: App {
    @StateObject private var fileHandler = FileHandler()
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    
    
    var body: some Scene {
        // settings window for normal launch
        WindowGroup("Settings") {
            SettingsView(isConversionContext: false)
                .frame(width: 350, height: 300)
                .environmentObject(fileHandler)
        }
        .windowResizability(.contentSize)
        .defaultSize(width: 350, height: 300)
        .handlesExternalEvents(matching: [])
        
        // conversion for opening files, does not seem to conver files tho...
        WindowGroup {
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
