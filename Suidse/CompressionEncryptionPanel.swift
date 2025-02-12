//
//  CompressionEncryptionPanel.swift
//  Suidse
//
//  Created by James Edmond on 2/8/25.
//

import SwiftUI

struct CompressionEncryptionPanel: View {
    @State private var compressionLevel: Double = 2
    @State private var password = ""
    @State private var repeatPassword = ""
    @State private var showPassword: Bool = false
    @State private var isHovered: Bool = false
    @State private var displayedLockImage = "lock.open.fill"
    @State private var useEncryption: Bool = false
    @State private var verifyIntegrity: Bool = true
    @State private var deleteFiles: Bool = false
    
    let compressionLabels: [String] = ["Store", "Fast", "", "Normal", "", "Slow"]
    
    var passwordsMatch: Bool {
        password == repeatPassword && !password.isEmpty
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            GroupBox {
                VStack(spacing: 15) {
                    VStack(spacing: 10) {
                        Text("Method: No Compression")
                            .padding(.leading, -110)
                        Slider(value: $compressionLevel, in: 0...5, step: 1)
                            .frame(width: 250)
                        HStack(spacing: 0) {
                            ForEach(Array(compressionLabels.enumerated()), id: \.offset) { index, label in
                                Text(label)
                                    .font(.caption)
                                    .frame(width: 250 / 5, alignment: .center)
                            }
                        }
                        .padding(.horizontal, -15)
                    }
                    
                    VStack(spacing: 10) {
                        HStack(spacing: 0) {
                            Text("Password: ")
                            SecureField("", text: $password)
                                .frame(width: 150)
                            Image(systemName: displayedLockImage)
                                .imageScale(.small)
                                .padding(.leading, 5)
                                .frame(width: 20)
                            Button(action: { showPassword.toggle() }) {
                                Image(systemName: showPassword ? "eye.slash" : "eye")
                                    .foregroundColor(isHovered ? .white : .primary)
                                    .imageScale(.small)
                            }
                            .buttonStyle(PlainButtonStyle())
                            .onHover { hovering in isHovered = hovering }
                            .padding(.leading, 5)
                        }
                        HStack(spacing: 0) {
                            Text("Repeat: ")
                            SecureField("", text: $repeatPassword)
                                .frame(width: 150)
                        }
                        .padding(.trailing, 24)
                    }
                    .onChange(of: passwordsMatch) { oldValue, newValue in
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            self.displayedLockImage = newValue ? "lock.fill" : "lock.open.fill"
                        }
                    }
                    
                    if passwordsMatch {
                        Toggle("Use AES-256 encryption", isOn: $useEncryption)
                            .padding(.trailing, 90)
                    }
                }
                .padding()
            }
            .padding(1)
            
            Toggle("Verify compression integrity", isOn: $verifyIntegrity)
                .padding(.leading, 10)
            Toggle("Delete file(s) after transfer", isOn: $deleteFiles)
                .padding(.leading, 10)
            
            Spacer()
        }
    }
}
