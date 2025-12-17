//
//  ImagePicker.swift
//  KJOMindCare
//
//  Created by DAMII on 12/12/25.
//

import SwiftUI
import PhotosUI

struct ImagePicker: View {
    
    @Binding var image: UIImage?
    @State private var selectedItem: PhotosPickerItem? = nil
    
    var body: some View {
        PhotosPicker(selection: $selectedItem, matching: .images) {
            Text("Seleccionar imagen")
        }
        .onChange(of: selectedItem) { newItem in
            Task {
                if let data = try? await newItem?.loadTransferable(type: Data.self) {
                    image = UIImage(data: data)
                }
            }
        }
    }
}
