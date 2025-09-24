//
//  PhotoGridView.swift
//  PhotoGallery
//
//  Created by Tabassum Akter Nusrat on 23/9/25.
//

import SwiftUI

struct PhotoGridView: View {
    @StateObject private var viewModel = GalleryViewModel()
    
    let columnsCount: Int = 3
    let spacing: CGFloat = 2
    let topTitleSpace: CGFloat = 40
    let horizontalPadding: CGFloat = 4
    
    var columns: [GridItem] {
        Array(repeating: GridItem(.flexible(), spacing: spacing), count: columnsCount)
    }
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .top) {
                Color.black.ignoresSafeArea()
                
                if viewModel.isLoading {
                    ProgressView("Loading...")
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .foregroundColor(.white)
                        .scaleEffect(1.5)
                } else {
                    GeometryReader { geo in
                        let totalInterColumnSpacing = CGFloat(columnsCount - 1) * spacing
                        let totalHorizontalPadding = horizontalPadding * 2
                        let availableWidth = geo.size.width - totalInterColumnSpacing - totalHorizontalPadding
                        let cellSide = floor(availableWidth / CGFloat(columnsCount))
                        
                        ScrollView {
                            LazyVGrid(columns: columns, spacing: spacing) {
                                ForEach(viewModel.photos) { photo in
                                    NavigationLink(destination: PhotoDetailView(photo: photo)) {
                                        AsyncImage(url: URL(string: photo.download_url)) { image in
                                            image
                                                .resizable()
                                                .scaledToFill()
                                                .frame(width: cellSide, height: cellSide)
                                                .clipped()
                                        } placeholder: {
                                            Color.gray.opacity(0.3)
                                                .frame(width: cellSide, height: cellSide)
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal, horizontalPadding)
                            .padding(.top, topTitleSpace)
                        }
                    }
                }
                
                Text("Gallery")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(.top, 0)
                    .frame(maxWidth: .infinity)
                    .background(
                        LinearGradient(colors: [Color.black.opacity(0.85), Color.clear],
                                       startPoint: .top, endPoint: .bottom)
                        .edgesIgnoringSafeArea(.top)
                    )
            }
            .onAppear { viewModel.fetchPhotos() }
            .navigationBarHidden(true)
        }
    }
}

#Preview {
    PhotoGridView()
}
