//
//  SortingConversionPanel.swift
//  Suidse
//
//  Created by James Edmond on 2/8/25.
//


import SwiftUI

struct SortingConversionPanel: View {
    @EnvironmentObject var fileHandler: FileHandler
    @State private var sortOption: String = "Name"
    @State private var selectedImageType: String = "JPEG"
    @State private var compressionLevel: Double = 2
    @State private var showError: Bool = false
    @State private var errorMessage: String = ""
    
    let sortOptions: [String] = ["Name", "Date", "Size"]
    
    var body: some View {
        VStack {
            HStack {
                Text("Sort by:")
                Picker("Sort by", selection: $sortOption) {
                    ForEach(sortOptions, id: \.self) { option in
                        Text(option)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
            }
            .padding()
            
            Button("Save As...") {
                FileSaver.saveConvertedFiles(
                    inputUrls: fileHandler.inputUrls,
                    selectedImageType: selectedImageType,
                    compressionLevel: compressionLevel,
                    isConversionContext: false
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
            .padding()
            
            Spacer()
        }
    }
}
