//
//  SettingsView.swift
//  Suidse
//
//  Created by James Edmond on 2/2/25.
//

import SwiftUI
import UniformTypeIdentifiers
import CryptoKit
import CoreGraphics
import CoreServices
import AVFoundation




extension UTType {
    static func from(imageType: String) -> UTType {
        switch imageType {
        case "JPEG": return .jpeg
        case "PNG": return .png
        case "HEIC": return .heic
        case "WEBP": return .webP
        case "TIFF": return .tiff
        case "BMP": return .bmp
        case "GIF": return .gif
        default: return .data
        }
    }
}

extension URL {
    func lowercasedPathExtension(_ pathExtension: String) -> URL {
        return self.appendingPathExtension(pathExtension.lowercased())
    }
}




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
                Toggle("Delete file(s) after transfer", isOn: $deleteFiles)
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
                    Spacer() // push content to the bottom
                    ZStack {
                        // Bottom layer of zstack is a full width HStack for the file count text
                        HStack {
                            if !fileHandler.inputUrls.isEmpty {
                                Text("\(fileHandler.inputUrls.count) file\(fileHandler.inputUrls.count == 1 ? "" : "s") selected")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .padding(.leading, 45)
                            }
                            Spacer()
                        }
                        // centered Save As button
                        Button("Save As...") {
                            // save logic goes here
                            saveConvertedFiles()
                        }
                        .alert("Error", isPresented: $showError) {
                            Button("OK", role: .cancel) { }
                        } message: {
                            Text(errorMessage)
                        }
                    }
                    .padding(.bottom, 10)
                }
                // overlay spans the same area as the main view
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .onAppear {
            // Debug print to verify the context and file count
            print("SettingsView appeared with conversion context: \(isConversionContext)")
            print("Number of files: \(fileHandler.inputUrls.count)")
        }
    }
    
    private func convertImage (_ image: NSImage, to format: String, compressionLevel: Int) -> Data?
    {
        guard let tiffData = image.tiffRepresentation,
              let bitmapRep = NSBitmapImageRep(data: tiffData) else {return nil}
        switch format {
        case "JPEG":
            let quality = compressionQuality(for: compressionLevel)
            return bitmapRep.representation(using: .jpeg, properties: [.compressionFactor: quality])
        case "PNG":
            return bitmapRep.representation(using: .png, properties: [:])
        case "HEIC":
                if #available(macOS 10.13.4, *) {
                    //heic conversion requires use of coregraphics since apple
                    guard let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil) else { return nil }
                    
                    let quality = compressionQuality(for: compressionLevel)
                    let data = NSMutableData()
                    guard let destination = CGImageDestinationCreateWithData(data, AVFileType.heic as CFString, 1, nil) else { return nil }
                    
                    let options: [CFString: Any] = [
                        kCGImageDestinationLossyCompressionQuality: quality,
                        kCGImagePropertyOrientation: cgImageOrientation.rawValue
                    ]
                    
                    CGImageDestinationAddImage(destination, cgImage, options as CFDictionary)
                    CGImageDestinationFinalize(destination)
                    
                    return data as Data
                } else {
                    return nil
                }
        case "WEBP":
            //webp needs a third party library im pretty sure..
            return nil
        case "TIFF":
            return bitmapRep.representation(using: .tiff, properties: [:])
        case "BMP":
            return bitmapRep.representation(using: .bmp, properties: [:])
        case "GIF":
            return bitmapRep.representation(using: .gif, properties: [:])
        default:
            return nil
        }
    }
    
    private func compressionQuality(for level: Int) -> Double {
        // Map slider levels 0-5 to quality values
        let levels: [Double] = [0.2, 0.4, 0.5, 0.6, 0.75, 0.9]
        return levels.indices.contains(level) ? levels[level] : 0.8
    }
    
    private func encrypt(data: Data, password: String) -> Data? {
        let passwordData = Data(password.utf8)
        let salt = Data([0x73, 0x61, 0x6C, 0x74, 0x44, 0x61, 0x74, 0x61]) //random salt for later, this is ai placeholders
        
        let key = SymmetricKey(size: .bits256)
        // ai placeholders
        return try? AES.GCM.seal(data, using: key).combined
    }
    
    private func handleFileSelection(_ result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            fileHandler.handleUrls(urls)
        case .failure(let error):
            errorMessage = error.localizedDescription
            showError = true
        }
    }
    
    private func saveConvertedFiles() {
        guard !fileHandler.inputUrls.isEmpty else {
            
            errorMessage = "No images slected"
            showError = true
            return
        }
        
        let savePanel = NSOpenPanel()
        savePanel.canChooseDirectories = true
        savePanel.canCreateDirectories = true
        savePanel.prompt = "Save"
        savePanel.message = "Choose a folder to save the converted images"
        
        savePanel.begin { response in
            guard response == .OK, let outputURL = savePanel.url else { return }
            
            let fileManager = FileManager.default
            let folderName = "Converted_\(Date().formatted(.dateTime.year().month().day().hour().minute().second()))"
            let outputFolder = outputURL.appendingPathComponent(folderName)
            
            do {
                try fileManager.createDirectory(at: outputFolder, withIntermediateDirectories: true, attributes: nil)
                
                for inputURL in self.fileHandler.inputUrls {
                    guard let image = NSImage(contentsOf: inputURL) else {continue}
                    
                    //gets the original files name but without its extension
                    let originalName = inputURL.deletingPathExtension( ).lastPathComponent
                    let outputPath = outputFolder
                        .appendingPathComponent(originalName)
                        .appendingPathExtension(self.selectedImageType.lowercased())
                    
                    //conversion
                    guard let convertedData = self.convertImage(image, to: self.selectedImageType, compressionLevel: Int(self.compressionLevel)) else {
                        self.errorMessage = "Faled to convert \(inputURL.lastPathComponent)"
                        self.showError = true
                        continue
                    }
                    
                    //save it
                    try convertedData.write(to: outputPath)
                    
                }
                
                //open the folder in Finder after conversion
                NSWorkspace.shared.activateFileViewerSelecting([outputFolder])
                
            } catch {
                self.errorMessage = error.localizedDescription
                self.showError = true
            }
        }
    }
    
    private var cgImageOrientation: CGImagePropertyOrientation {
        // appropriate orientation based on image metadata
        return .up
    }
    
    
    
}



#Preview {
    SettingsView(isConversionContext: true)
        .environmentObject(FileHandler())
}

