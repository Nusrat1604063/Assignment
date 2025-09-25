//
//  NetworkManager.swift
//  PhotoGallery
//
//  Created by Tabassum Akter Nusrat on 23/9/25.
//

import Foundation
import Combine

class NetworkManager {
    static let shared = NetworkManager()
    var urlString = "https://picsum.photos/v2/list?page=1&limit=50" //loading first 50 images from first page
    
    private init() {}
    
    //For testing purpose 
    init(urlString: String) {
        self.urlString = urlString
    }
    
    func fetchPhotos() -> AnyPublisher<[Photo], Error> {
        
        guard let url = URL(string: urlString) else {
            return Fail(error: URLError(.badURL))
                .eraseToAnyPublisher()
        }
        
        return URLSession.shared.dataTaskPublisher(for: url)
            .tryMap { output in
                guard let response = output.response as? HTTPURLResponse,
                      response.statusCode == 200 else {
                    throw URLError(.badServerResponse)
                }
                return output.data
            }
            .decode(type: [Photo].self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}
