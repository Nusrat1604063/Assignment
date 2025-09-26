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
    @State private var showToast = false
    @State private var showShareSheet = false


    var body: some View {
        ZStack {
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
            .sheet(isPresented: $showShareSheet) {
                if let image = loader.image {
                    ActivityView(activityItems: [image], showShareSheet: $showShareSheet)
                }
            }
            .onAppear {
                loader.load()
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: downloadButton)
            .background(Color.black.edgesIgnoringSafeArea(.all))
            
            HStack {
                Spacer()
                Button(action: { showShareSheet = true }) {
                    Image(systemName: "square.and.arrow.up")
                        .font(.title2)
                        .foregroundColor(.blue)
                }
                Spacer()
            }
            .frame(maxHeight: .infinity, alignment: .bottom)
            .padding(.bottom, 16)
            
            if showToast {
                VStack {
                    Text("Photo Saved")
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(Color.black.opacity(0.8))
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        .padding(.top, 40)
                }
            }
            
        }
    }
    
    private var downloadButton: some View {
           Button(action: saveImage) {
               Image(systemName: "arrow.down.to.line")
                   .font(.body)
                   .foregroundColor(.white)
           }
       }
    
    private func saveImage() {
        guard let image = loader.image else { return }
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        showToast = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            showToast = false
        }
    }
}

struct ActivityView: UIViewControllerRepresentable {
    let activityItems: [Any]
    @Binding var showShareSheet: Bool
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        controller.completionWithItemsHandler = { _, _, _, _ in showShareSheet = false }
        return controller
    }
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
 let url = URL(string: "https://picsum.photos/400/400")
 let loader = ImageLoader(url: url)
 PhotoDetailView(loader: loader)
}
