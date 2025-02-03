//
//  ContentView.swift
//  Suidse
//
//  Created by James Edmond on 2/2/25.
//

import SwiftUI



struct SettingsView: View {
    
    @State private var compressionLevel: Double = 2
    @State private var password = ""
    @State private var repeatPassword = ""
    @State private var showPassword: Bool = false
    @State private var useEncryption: Bool = false
    @State private var verifyIntegrity: Bool = true
    @State private var deleteFiles: Bool = false
    @State private var selectedImageType = "JPEG"
    
    let compressionLabels: [String] = ["Store", "Fast", "", "Normal", "", "Slow"]
    let imageTypes: [String] = ["JPEG", "PNG", "HEIC", "WEBP", "TIFF", "BMP", "GIF"]
    
    var body: some View {
        VStack(spacing: 20){
            GroupBox {
                VStack(spacing: 15){
                    VStack {
                        Text("Method: No Compression")
                        Slider(value: $compressionLevel, in: 0...5, step: 1)
                            
                        
                        HStack {
                            ForEach(Array(compressionLabels.enumerated()), id: \.offset) { index, label in
                                Text(label)
                                    .font(.caption)
                                    .frame(width: 35, alignment: .center)
                                    .offset(x: index == 0 ? -20 : (index == 5 ? 20 : 5))
                                
                            }
                        }
                        .padding(.horizontal, 10)
                    }
                    
                    VStack(spacing: 10) {
                        HStack {
                            Text("Password: ")
                            SecureField("", text: $password)
                                .frame(width: 150)
                            Button(action: {
                                showPassword.toggle() }) {
                                    Image(systemName: showPassword ? "eye.slash" : "eye")
                            }
                        }
                        HStack {
                            Text("Repeat: ")
                            SecureField("", text: $repeatPassword)
                                .frame(width: 150)
                            Image(systemName: password == repeatPassword && !password.isEmpty ? "lock.fill" : "lock.open")
                        }
                    }
                    
                    //encryption check
                    Toggle("Use AES-256 encryption", isOn: $useEncryption)
                }
                .padding()
            }
            .padding(.horizontal, 20)
            //integrity and delete previous options
            
            Toggle("Verify compression integrity", isOn: $verifyIntegrity)
            Toggle("Delete file(s) after compression", isOn: $deleteFiles)
            
            Spacer()
        }
        .padding()
        .fixedSize()
        .frame(width: 345, height: 390)
        .toolbar {
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
}


#Preview {
    SettingsView()
}
