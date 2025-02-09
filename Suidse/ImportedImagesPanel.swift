//
//  ImportedImagesPanel.swift
//  Suidse
//
//  Created by James Edmond on 2/8/25.
//



import SwiftUI
import UniformTypeIdentifiers

struct ImportedImagesPanel: View {
    @EnvironmentObject var fileHandler: FileHandler
    @State private var showFileImporter = false

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Imported Images")
                    .font(.headline)
                Spacer()
                Button(action: { showFileImporter.toggle() }) {
                    Image(systemName: "plus")
                        .padding(8)
                }
                .buttonStyle(BorderlessButtonStyle())
                .fileImporter(isPresented: $showFileImporter,
                              allowedContentTypes: [.image],
                              allowsMultipleSelection: true) { result in
                    switch result {
                    case .success(let urls):
                        fileHandler.inputUrls.append(contentsOf: urls)
                    case .failure(let error):
                        print("Error importing files: \(error.localizedDescription)")
                    }
                }
            }
            .padding([.top, .horizontal])
            
            List {
                ForEach(fileHandler.inputUrls, id: \.self) { url in
                    Text(url.lastPathComponent)
                }
            }
        }
    }
}
