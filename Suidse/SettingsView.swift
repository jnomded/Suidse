//
//  SettingsView.swift
//  Suidse
//
//  Created by James Edmond on 2/2/25.
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
    
    @State private var showError: Bool = false
    @State private var errorMessage: String = ""
    
    var passwordsMatch: Bool {
        password == repeatPassword && !password.isEmpty
    }
    
    var body: some View {
        if isConversionContext {
            ZStack {
                VStack(alignment: .leading) {
                    GroupBox {
                        VStack(spacing: 15) {
                            VStack(spacing: 10) {
                                Text("Method: No Compression")
                                    .padding(.leading, -110)
                                Slider(value: $compressionLevel, in: 0...5, step: 1)
                                    .frame(width: 250)
                                HStack(spacing: 0) {
                                    ForEach(0..<6) { _ in
                                        Text("")
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
                }
                .padding(.top, -30)
                .fixedSize()
                .animation(.easeInOut, value: passwordsMatch)
                .toolbar {
                    ToolbarItem(placement: .primaryAction) {
                        Picker("Format", selection: $selectedImageType) {
                            ForEach(["JPEG", "PNG", "HEIC", "WEBP", "TIFF", "BMP", "GIF"], id: \.self) {
                                Text($0)
                            }
                        }
                        .frame(width: 75)
                    }
                }
                
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
                                isConversionContext: true
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
        } else {
            HStack(spacing: 0) {
                ImportedImagesPanel()
                    .frame(minWidth: 200, minHeight: 300)
                Divider()
                VStack(spacing: 0) {
                    SortingConversionPanel()
                        .frame(minHeight: 150)
                    Divider()
                    CompressionEncryptionPanel()
                        .frame(minHeight: 150)
                }
                .frame(minWidth: 300)
            }
            .padding()
        }
    }
}
struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(isConversionContext: false)
            .environmentObject(FileHandler.shared)
    }
}
