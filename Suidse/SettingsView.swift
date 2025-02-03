//
//  ContentView.swift
//  Suidse
//
//  Created by James Edmond on 2/2/25.
//

import SwiftUI



struct SettingsView: View {
    
    let isConversionContext: Bool
    
    @State private var compressionLevel: Double = 2
    @State private var password = ""
    @State private var repeatPassword = ""
    @State private var showPassword: Bool = false
    @State private var isHovered: Bool = false
    @State private var useEncryption: Bool = false
    @State private var verifyIntegrity: Bool = true
    @State private var deleteFiles: Bool = false
    @State private var selectedImageType = "JPEG"
    
    let compressionLabels: [String] = ["Store", "Fast", "", "Normal", "", "Slow"]
    let imageTypes: [String] = ["JPEG", "PNG", "HEIC", "WEBP", "TIFF", "BMP", "GIF"]
    
    var body: some View {
        VStack(alignment: .leading){
            GroupBox {
                VStack(spacing: 15){
                    VStack {
                        Text("Method: No Compression")
                        Slider(value: $compressionLevel, in: 0...5, step: 1)
                            .frame(width: 250)
                        
                        HStack (spacing: 0){
                            ForEach(Array(compressionLabels.enumerated()), id: \.offset) { index, label in
                                Text(label)
                                    .font(.caption)
                                    .frame(width: 250 / 5, alignment: .center)
                                //dividing slider width equally for # of intervals
                            }
                        }
                        .padding(.horizontal, -15)
                    }
                    
                    VStack( spacing: 10) {
                        HStack(spacing: 0){
                            Text("Password: ")
                                .frame(alignment: .trailing)
                            SecureField("", text: $password)
                                .frame(width: 150)
                            
                            Image(systemName: password == repeatPassword && !password.isEmpty ? "lock.fill" : "lock.open.fill")
                                .imageScale(.small)
                                .padding(.leading, 5)
                            
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
                        HStack (spacing: 0){
                            Text("Repeat: ")
                                .frame(alignment: .trailing)
                                
                            SecureField("", text: $repeatPassword)
                                .frame(width: 150)
                        }
                        .padding(.trailing, 22)
                    }
                    
                    //encryption check
                    Toggle("Use AES-256 encryption", isOn: $useEncryption)
                        .padding(.trailing, 90)
                        
                }
                //inside groupbox padding
                .padding()
            }
            //outside groupbox padding
            .padding(1)
            
            //integrity and delete previous options
            
            Toggle("Verify compression integrity", isOn: $verifyIntegrity)
                .padding(.leading, 10)
            Toggle("Delete file(s) after compression", isOn: $deleteFiles)
                .padding(.leading, 10)
            
            if isConversionContext {
                Button("Save As...") {
                    //save logic goes here (ง •̀_•́)ง
                }
                .padding(.top, 9)
                .frame(maxWidth: .infinity)
                
                
                
            }
            
           
        }
        //VStack padding
        .padding(.top, 0)
        .fixedSize() //i have no idea why this straightens things out???
        .frame(width: 350, height: isConversionContext ? 350 : 300)
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
       
    }
}


#Preview {
    SettingsView(isConversionContext: true)
}
