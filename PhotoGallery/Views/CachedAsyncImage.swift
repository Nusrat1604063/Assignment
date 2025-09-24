//
//  CachedAsyncImage.swift
//  PhotoGallery
//
//  Created by Tabassum Akter Nusrat on 24/9/25.
//

import SwiftUI

struct CachedAsyncImage: View {
    @ObservedObject var loader: ImageLoader
    let placeholder: Image = Image(systemName: "photo")

    var body: some View {
        Group {
            if let uiImage = loader.image {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
            } else {
                placeholder
            }
        }
        .onAppear { loader.load() }
        .onDisappear { loader.cancel() }
    }
}

