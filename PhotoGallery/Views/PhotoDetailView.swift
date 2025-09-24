//
//  PhotoDetailView.swift
//  PhotoGallery
//
//  Created by Tabassum Akter Nusrat on 23/9/25.
//

import SwiftUI

struct PhotoDetailView: View {
    @ObservedObject var loader: ImageLoader  // shared loader

    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0

    var body: some View {
        VStack {
            if let image = loader.image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .scaleEffect(scale)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .gesture(
                        MagnificationGesture()
                            .onChanged { value in
                                let delta = value / lastScale
                                scale *= delta
                                lastScale = value
                            }
                            .onEnded { _ in
                                lastScale = 1.0
                            }
                    )
            } else {
                ProgressView()
                    .scaleEffect(1.5)
                    .foregroundColor(.blue)
            }
            Spacer()
        }
        .onAppear {
            loader.load()
        }
        .navigationBarTitleDisplayMode(.inline)
        .background(Color.black.edgesIgnoringSafeArea(.all))
    }
}

#Preview {
 let url = URL(string: "https://picsum.photos/400/400")
 let loader = ImageLoader(url: url)
 PhotoDetailView(loader: loader)
}
