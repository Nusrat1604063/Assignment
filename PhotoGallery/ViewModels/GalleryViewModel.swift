//
//  GalleryViewModel.swift
//  PhotoGallery
//
//  Created by Tabassum Akter Nusrat on 23/9/25.
//

import Foundation
import Combine

class GalleryViewModel: ObservableObject {
    @Published var photos: [Photo] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    
    private(set) var loaders: [URL: ImageLoader] = [:]

    private var cancellables = Set<AnyCancellable>()
    private let networkManager: NetworkManager
    
    // Use singleton for production
    init() {
        self.networkManager = .shared
    }
    
    // For testing purpose
    init(networkManager: NetworkManager) {
        self.networkManager = networkManager
    }
    
    func fetchPhotos() {
        isLoading = true
        
        networkManager.fetchPhotos()
            .sink { [weak self] completion in
                self?.isLoading = false
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                    print("Error fetching photos: \(error.localizedDescription)")
                }
            } receiveValue: { [weak self] photos in
                self?.photos = photos
            }
            .store(in: &cancellables)
    }
    
    func loader(for photo: Photo) -> ImageLoader {
            let url = URL(string: photo.download_url)!
            if let existing = loaders[url] { return existing }
            let newLoader = ImageLoader(url: url)
            loaders[url] = newLoader
            return newLoader
        }
}



