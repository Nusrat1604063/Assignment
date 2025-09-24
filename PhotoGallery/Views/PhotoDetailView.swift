//
//  PhotoDetailView.swift
//  PhotoGallery
//
//  Created by Tabassum Akter Nusrat on 23/9/25.
//

import SwiftUI

struct PhotoDetailView: View {
    let photo: Photo
    
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    
    var body: some View {
        VStack {
            AsyncImage(url: URL(string: photo.download_url)) { image in
                image
                    .resizable()
                    .scaledToFit()
                    .scaleEffect(scale)
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
            } placeholder: {
                ProgressView()
                    .scaleEffect(1.5)
                    .foregroundColor(.blue)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            Spacer()
        }
        .navigationBarTitleDisplayMode(.inline)
        .background(Color.black.edgesIgnoringSafeArea(.all))
    }
}

#Preview {
    PhotoDetailView(photo: Photo(
            id: "4",
            author: "Preview Author",
            width: 120,
            height: 120,
            url: "https://picsum.photos/id/1/400/600",
            download_url: "https://picsum.photos/400/600"
        ))
}
