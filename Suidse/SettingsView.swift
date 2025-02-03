//
//  ContentView.swift
//  Suidse
//
//  Created by James Edmond on 2/2/25.
//

import SwiftUI

struct SettingsView: View {
    
    let isConversionContext: Bool
    
    @State private var compressionLevel: Double = 2
    @State private var password = ""
    @State private var repeatPassword = ""
    @State private var showPassword: Bool = false
    @State private var isHovered: Bool = false
    @State private var displayedLockImage = "lock.open.fill"
    @State private var useEncryption: Bool = false
    @State private var verifyIntegrity: Bool = true
    @State private var deleteFiles: Bool = false
    @State private var selectedImageType = "JPEG"
    
    var passwordsMatch: Bool {
        password == repeatPassword && !password.isEmpty
    } //for our encryption animate
    
    let compressionLabels: [String] = ["Store", "Fast", "", "Normal", "", "Slow"]
    let imageTypes: [String] = ["JPEG", "PNG", "HEIC", "WEBP", "TIFF", "BMP", "GIF"]
    
    var body: some View {
        // Wrap the main content in a ZStack
        ZStack {
            VStack(alignment: .leading) {
                GroupBox {
                    VStack(spacing: 15) {
                        VStack (spacing: 10) {
                            Text("Method: No Compression")
                                .padding(.leading, -110)
                            Slider(value: $compressionLevel, in: 0...5, step: 1)
                                .frame(width: 250)
                            
                            HStack (spacing: 0) {
                                ForEach(Array(compressionLabels.enumerated()), id: \.offset) { index, label in
                                    Text(label)
                                        .font(.caption)
                                        .frame(width: 250 / 5, alignment: .center)
                                    //dividing slider width equally for # of intervals
                                }
                            }
                            .padding(.horizontal, -15) // groupbox edges
                        }
                        
                        VStack(spacing: 10) {
                            HStack(spacing: 0) {
                                Text("Password: ")
                                    .frame(alignment: .trailing)
                                SecureField("", text: $password)
                                    .frame(width: 150)
                                
                                Image(systemName: displayedLockImage)
                                    .imageScale(.small)
                                    .padding(.leading, 5)
                                    .frame(width: 20)
                                
                                Button(action: {
                                    showPassword.toggle()
                                }) {
                                    Image(systemName: showPassword ? "eye.slash" : "eye")
                                        .foregroundColor(isHovered ? .white : .primary)
                                        .imageScale(.small)
                                }
                                .buttonStyle(PlainButtonStyle())
                                .onHover { hovering in
                                    isHovered = hovering
                                }
                                .padding(.leading, 5)
                            }
                            HStack(spacing: 0) {
                                Text("Repeat: ")
                                    .frame(alignment: .trailing)
                                
                                SecureField("", text: $repeatPassword)
                                    .frame(width: 150)
                            }
                            .padding(.trailing, 24) //aligning text fields
                        }
                        
                        .onChange(of: passwordsMatch) { oldValue, newValue in
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                // only update if the condition still matches the delayed new value
                                if self.passwordsMatch == newValue {
                                    self.displayedLockImage = newValue ? "lock.fill" : "lock.open.fill"
                                }
                            }
                        }
                        
                        //encryption check
                        if passwordsMatch {
                            Toggle("Use AES-256 encryption", isOn: $useEncryption)
                                .padding(.trailing, 90)
                        }
                        
                    }
                    //inside groupbox padding
                    .padding()
                }
                //outside groupbox padding
                .padding(1)
                
                //integrity and delete previous options
                
                Toggle("Verify compression integrity", isOn: $verifyIntegrity)
                    .padding(.leading, 10)
                Toggle("Delete file(s) after compression", isOn: $deleteFiles)
                    .padding(.leading, 10)
                
            }
            //VStack padding
            .padding(.top, isConversionContext ? -30 : -10)
            .fixedSize() //i have no idea why this straightens things out???
            
            //animate
            .animation(.easeInOut, value: passwordsMatch)
            .toolbar {
                if isConversionContext {
                    ToolbarItem(placement: .primaryAction) {
                        Picker("Format", selection: $selectedImageType) {
                            ForEach(imageTypes, id: \.self) {
                                Text($0)
                            }
                        }
                        .frame(width: 75)
                    }
                }
            }
            
            // save as button placed as overlay
            if isConversionContext {
                VStack {
                    Spacer() // pushes button to the bottom
                    Button("Save As...") {
                        //save logic goes here (ง •̀_•́)ง
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.bottom, 10)
                }
                // overlay needs to span the same area as the main view
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }
}


#Preview {
    SettingsView(isConversionContext: false)
}
