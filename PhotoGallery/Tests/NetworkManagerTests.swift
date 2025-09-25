//
//  NetworkManagerTests.swift
//  PhotoGalleryTests
//
//  Created by Tabassum Akter Nusrat on 25/9/25.
//

import XCTest
import Combine
@testable import PhotoGallery

final class NetworkManagerTests: XCTestCase {
    
    var cancellables : Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        cancellables = Set<AnyCancellable>()
    }
    
    override func tearDown() {
        cancellables.removeAll()
        super.tearDown()
    }
    
    //failure case
    func test_FetchPhotosWithInvalidURL_ReturnsBadURLError() {
        let networkManager = NetworkManager(urlString: "")
        let expectation = XCTestExpectation(description: "Invalid URL should return badURL error")
        
        networkManager.fetchPhotos()
            .sink { completion in
                switch completion {
                case .finished:
                    XCTFail("Expected failure with badURL error, but succeeded")
                case .failure(let error):
                    XCTAssertTrue(error is URLError, "Error should be a URLError")
                    XCTAssertEqual((error as? URLError)?.code, .badURL, "Error should be badURL")
                    expectation.fulfill()
                }
            } receiveValue: { _ in
                XCTFail("Expected no value for invalid URL")
            }
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 2.0)
    }
    
    //success case
    func test_FetchPhotosWithValidURL_ReturnsNonEmptyArray() {
        let networkManager = NetworkManager.shared
        let expectation = XCTestExpectation(description: "Valid URL should return non-empty photos")
        
        networkManager.fetchPhotos()
            .sink { completion in
                if case .failure(let error) = completion {
                    XCTFail("Expected success, but failed with error: \(error)")
                }
            } receiveValue: { photos in
                XCTAssertFalse(photos.isEmpty, "Expected array of photos")
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 5.0)
    }
}
