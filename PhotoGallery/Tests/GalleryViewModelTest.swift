//
//  GalleryViewModelTest.swift
//  PhotoGalleryTests
//
//  Created by Tabassum Akter Nusrat on 26/9/25.
//

import XCTest
import Combine
@testable import PhotoGallery

class MockImageLoader {
    private let url: URL?
    init(url: URL?) { self.url = url }
    
    func getURL() -> URL? { return url }
}

class MockNetworkManager: NetworkManager {
    var photos: [Photo] = []
    var error: Error?
    
    override init(urlString: String) {
        super.init(urlString: urlString)
    }
    
    override func fetchPhotos() -> AnyPublisher<[Photo], Error> {
        if let error = error {
            return Fail(error: error).eraseToAnyPublisher()
        }
        return Just(photos).setFailureType(to: Error.self).eraseToAnyPublisher()
    }
}

final class GalleryViewModelTest: XCTestCase {
    var viewModel: GalleryViewModel!
    var mockNetworkManager: MockNetworkManager!
    
    override func setUp() {
        super.setUp()
        mockNetworkManager = MockNetworkManager(urlString: "https://test.com")
        viewModel = GalleryViewModel(networkManager: mockNetworkManager)
    }
    
    override func tearDown() {
        viewModel = nil
        mockNetworkManager = nil
        super.tearDown()
    }
    
    func test_FetchPhotosWithValidURL_PopulatesPhotos() {
        mockNetworkManager.photos = [
            Photo(id: "1", author: "Test", width: 100, height: 100, url: "https://example.com", download_url: "https://example.com/1.jpg")
        ]
        viewModel.fetchPhotos()
        
        XCTAssertTrue(viewModel.isLoading, "isLoading is true while fetching")
        XCTAssertEqual(viewModel.photos.count, 1, "Should load one photo")
        XCTAssertEqual(viewModel.photos.first?.id, "1", "Photo ID should match")
        XCTAssertNil(viewModel.errorMessage, "Error message should be nil")
    }
    
    func test_FetchPhotosWithInvalidURL_ReturnsBadURLError() {
        mockNetworkManager.error = URLError(.badURL)
        
        viewModel.fetchPhotos()
        
        XCTAssertTrue(viewModel.isLoading, "isLoading is true while fetching")
        XCTAssertTrue(viewModel.photos.isEmpty, "Photo is empty on error")
        XCTAssertEqual(viewModel.errorMessage, URLError(.badURL).localizedDescription, "Error message is bad URL error")
    }
    
    func test_LoaderForPhoto_ReturnsCachedInstance() {
            let photo = Photo(id: "1", author: "Test", width: 100, height: 100, url: "https://example.com", download_url: "https://example.com/1.jpg")
            let url = URL(string: photo.download_url)!
    
            let loader1 = viewModel.loader(for: photo)
            let loader2 = viewModel.loader(for: photo)
  
            XCTAssertEqual(loader1.getURL(), url, "Loader URL should match photo download_url")
            XCTAssertTrue(loader1 === loader2, "Should return the same loader instance")
        }
}
