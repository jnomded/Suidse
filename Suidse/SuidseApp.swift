//
//  SuidseApp.swift
//  Suidse
//
//  Created by James Edmond on 2/2/25.
//

import SwiftUI

@main
struct SuidseApp: App {
    var body: some Scene {
        WindowGroup {
            SettingsView(isConversionContext: false)
                .frame(width: 350, height: 300)
                
        }
        .windowResizability(.contentSize)
        .defaultSize(width: 350, height: 300)
        
        WindowGroup {
            SettingsView(isConversionContext: true)
                .frame(width: 350, height: 325)
                
        }
        .windowResizability(.contentSize)
        .defaultSize(width: 350, height: 325)
        
        .handlesExternalEvents(matching: ["conversion"])
        
    }
}

