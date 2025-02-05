//
//  FileSaver.swift
//  Suidse
//
//  Created by James Edmond on 2/5/25.
//

import AppKit

class FileSaver {
    static func saveConvertedFiles(
        inputUrls: [URL],
        selectedImageType: String,
        compressionLevel: Double,
        isConversionContext: Bool,
        completion: @escaping (String?) -> Void
    ) {
        guard !inputUrls.isEmpty else {
            completion("No images selected")
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
            let destinationFolder: URL
            
            if inputUrls.count > 1 {
                let folderName = "Converted_\(Date().formatted(.dateTime.year().month().day().hour().minute().second()))"
                destinationFolder = outputURL.appendingPathComponent(folderName)
                do {
                    try fileManager.createDirectory(at: destinationFolder, withIntermediateDirectories: true, attributes: nil)
                } catch {
                    completion("Could not create folder: \(error.localizedDescription)")
                    return
                }
            } else {
                destinationFolder = outputURL
            }
            
            for inputURL in inputUrls {
                guard let image = NSImage(contentsOf: inputURL) else { continue }
                
                let originalName = inputURL.deletingPathExtension().lastPathComponent
                let outputPath = destinationFolder
                    .appendingPathComponent(originalName)
                    .appendingPathExtension(selectedImageType.lowercased())
                
                guard let convertedData = ImageConverter.convertImage(image, to: selectedImageType, compressionLevel: Int(compressionLevel)) else {
                    completion("Failed to convert \(inputURL.lastPathComponent)")
                    continue
                }
                
                do {
                    try convertedData.write(to: outputPath)
                } catch {
                    completion("Error writing file \(outputPath.lastPathComponent): \(error.localizedDescription)")
                }
            }
            
            if inputUrls.count > 1 {
                NSWorkspace.shared.activateFileViewerSelecting([destinationFolder])
            } else {
                let originalName = inputUrls.first!.deletingPathExtension().lastPathComponent
                let outputPath = destinationFolder
                    .appendingPathComponent(originalName)
                    .appendingPathExtension(selectedImageType.lowercased())
                NSWorkspace.shared.activateFileViewerSelecting([outputPath])
            }
            
            if isConversionContext {
                NSApplication.shared.terminate(nil)
            }
            
            completion(nil)
        }
    }
}
