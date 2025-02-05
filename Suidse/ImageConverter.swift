//
//  ImageConverter.swift
//  Suidse
//
//  Created by James Edmond on 2/5/25.
//

import AppKit
import CoreGraphics
import AVFoundation

class ImageConverter {
    static func convertImage(_ image: NSImage, to format: String, compressionLevel: Int) -> Data? {
        guard let tiffData = image.tiffRepresentation,
              let bitmapRep = NSBitmapImageRep(data: tiffData) else { return nil }
        
        switch format {
        case "JPEG":
            let quality = compressionQuality(for: compressionLevel)
            return bitmapRep.representation(using: .jpeg, properties: [.compressionFactor: quality])
        case "PNG":
            return bitmapRep.representation(using: .png, properties: [:])
        case "HEIC":
            if #available(macOS 10.13.4, *) {
                guard let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil) else { return nil }
                
                let quality = compressionQuality(for: compressionLevel)
                let data = NSMutableData()
                guard let destination = CGImageDestinationCreateWithData(data, AVFileType.heic as CFString, 1, nil) else { return nil }
                
                let options: [CFString: Any] = [
                    kCGImageDestinationLossyCompressionQuality: quality,
                    kCGImagePropertyOrientation: CGImagePropertyOrientation.up.rawValue
                ]
                
                CGImageDestinationAddImage(destination, cgImage, options as CFDictionary)
                CGImageDestinationFinalize(destination)
                
                return data as Data
            } else {
                return nil
            }
        case "WEBP":
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
    
    static func compressionQuality(for level: Int) -> Double {
        let levels: [Double] = [0.2, 0.4, 0.5, 0.6, 0.75, 0.9]
        return levels.indices.contains(level) ? levels[level] : 0.8
    }
}
