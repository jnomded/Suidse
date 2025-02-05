//
//  Extensions.swift
//  Suidse
//
//  Created by James Edmond on 2/5/25.
//

import Foundation
import UniformTypeIdentifiers

extension URL {
    func lowercasedPathExtension(_ pathExtension: String) -> URL {
        return self.appendingPathExtension(pathExtension.lowercased())
    }
}

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
