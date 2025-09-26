//
//  ImageLoader.swift
//  PhotoGallery
//
//  Created by Tabassum Akter Nusrat on 24/9/25.
//

import SwiftUI
import Foundation
import Combine

class ImageLoader: ObservableObject {
    @Published var image: UIImage?
    
    private let url: URL?

    private var cancellable: AnyCancellable?
    private static let cache = NSCache<NSURL, UIImage>()
    
    init(url: URL?) {
           self.url = url
       }

    func load() {
        guard let url = url else { return }

        if let cached = Self.cache.object(forKey: url as NSURL) {  //if image already exists
            print("Cache hit for \(url)")
            self.image = cached
            return
        }
        
        cancellable = URLSession.shared.dataTaskPublisher(for: url)
            .map { UIImage(data: $0.data) }
            .replaceError(with: nil)
            .handleEvents(receiveOutput: { image in
                if let image = image {
                    Self.cache.setObject(image, forKey: url as NSURL) //caches the downloaded image for future use
                }
            })
            .receive(on: DispatchQueue.main)
            .assign(to: \.image, on: self)
    }

    func cancel() {
        cancellable?.cancel()
    }
    
    // For testing purpose
    func getURL() -> URL? {
        return url
    }
}
