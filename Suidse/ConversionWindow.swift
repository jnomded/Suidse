//
//  ConversionWindow.swift
//  Suidse
//
//  Created by James Edmond on 2/3/25.
//
import SwiftUI

struct ConversionWindow: View {
    @State private var selectedFormat = "JPEG"
    
    let formats: [String] = ["JPEG", "PNG", "HEIC", "WEBP", "TIFF", "BMP", "GIF"]
    var body: some View {
        VStack {
            Picker("Convert to:", selection: $selectedFormat) {
                ForEach(formats, id: \.self) {format in
                    Text(format)
                }
            }
            .padding(10)
            
            Button("Save As...") {
                //logic to be decided (ง •̀_•́)ง‼
            }
        }
        .frame(width: 175, height: 150)
    }
}

#Preview {
    ConversionWindow()
}
