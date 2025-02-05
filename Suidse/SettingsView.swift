//
//  SettingsView.swift
//  Suidse
//
//  Created by James Edmond on 2/2/25.
//
import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var fileHandler: FileHandler
    
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
    
    @State private var selectedImageURLs: [URL] = []
    @State private var showError: Bool = false
    @State private var errorMessage: String = ""
    @State private var showFilePicker = false
    
    var passwordsMatch: Bool {
        password == repeatPassword && !password.isEmpty
    }
    
    let compressionLabels: [String] = ["Store", "Fast", "", "Normal", "", "Slow"]
    let imageTypes: [String] = ["JPEG", "PNG", "HEIC", "WEBP", "TIFF", "BMP", "GIF"]
    
    var body: some View {
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
                                }
                            }
                            .padding(.horizontal, -15)
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
                            .padding(.trailing, 24)
                        }
                        .onChange(of: passwordsMatch) { oldValue, newValue in
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                if self.passwordsMatch == newValue {
                                    self.displayedLockImage = newValue ? "lock.fill" : "lock.open.fill"
                                }
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
            }
            .padding(.top, isConversionContext ? -30 : -10)
            .fixedSize()
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
            
            if isConversionContext {
                VStack {
                    Spacer()
                    ZStack {
                        HStack {
                            if !fileHandler.inputUrls.isEmpty {
                                Text("\(fileHandler.inputUrls.count) file\(fileHandler.inputUrls.count == 1 ? "" : "s") selected")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .padding(.leading, 40)
                            }
                            Spacer()
                        }
                        Button("Save As...") {
                            FileSaver.saveConvertedFiles(
                                inputUrls: fileHandler.inputUrls,
                                selectedImageType: selectedImageType,
                                compressionLevel: compressionLevel,
                                isConversionContext: isConversionContext
                            ) { error in
                                if let error = error {
                                    errorMessage = error
                                    showError = true
                                }
                            }
                        }
                        .alert("Error", isPresented: $showError) {
                            Button("OK", role: .cancel) { }
                        } message: {
                            Text(errorMessage)
                        }
                    }
                    .padding(.bottom, 10)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .onAppear {
            print("SettingsView appeared with conversion context: \(isConversionContext)")
            print("Number of files: \(fileHandler.inputUrls.count)")
        }
    }
}
