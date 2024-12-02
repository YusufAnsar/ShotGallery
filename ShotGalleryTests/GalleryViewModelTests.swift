//
//  GalleryViewModelTests.swift
//  ShotGalleryTests
//
//  Created by Yusuf Ansar on 01/12/24.
//

import XCTest
import Photos
@testable import ShotGallery

final class GalleryViewModelTests: XCTestCase {

    var viewModel: GalleryViewModel!
    var mockPhotoLibraryManager: MockPhotoLibraryManager!

    override func setUp() {
        super.setUp()
        mockPhotoLibraryManager = MockPhotoLibraryManager()
        viewModel = GalleryViewModel(photoLibraryManager: mockPhotoLibraryManager)
    }

    override func tearDown() {
        viewModel = nil
        mockPhotoLibraryManager = nil
        super.tearDown()
    }

    // MARK: - Tests

    func testInitialization_LoadsScreenshots() {
        // Given
        let mockAssets = createMockAssets()
        mockPhotoLibraryManager.mockedScreenshots = mockAssets

        // When
        let expectation = expectation(description: "Screenshots should be loaded")
        viewModel.loadScreenshots()
        let delayInSeconds = 1.0
        DispatchQueue.global().asyncAfter(deadline: .now() + delayInSeconds) {
            // Fulfill the expectation after the delay
            expectation.fulfill()
        }

        // Wait for the expectation to be fulfilled
        wait(for: [expectation], timeout: delayInSeconds + 1.0)

        // Then
        XCTAssertEqual(viewModel.screenshots.count, mockAssets.count, "Expected the viewModel to load screenshots")
    }

    func testSelectAsset_ValidIndex() {
        // Given
        let mockAssets = createMockAssets()
        mockPhotoLibraryManager.mockedScreenshots = mockAssets
        let expectation = expectation(description: "Screenshots should be loaded")
        viewModel.loadScreenshots()
        let delayInSeconds = 1.0
        DispatchQueue.global().asyncAfter(deadline: .now() + delayInSeconds) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: delayInSeconds + 1.0)

        // When
        viewModel.selectAsset(at: 2)

        // Then
        XCTAssertEqual(viewModel.selectedAsset, mockAssets[2], "Expected the selected asset to match the index")
    }

    func testSelectAsset_InvalidIndex() {
        // Given
        let mockAssets = createMockAssets(count: 5)
        mockPhotoLibraryManager.mockedScreenshots = mockAssets
        let expectation = expectation(description: "Screenshots should be loaded")
        viewModel.loadScreenshots()
        let delayInSeconds = 1.0
        DispatchQueue.global().asyncAfter(deadline: .now() + delayInSeconds) {
            // Fulfill the expectation after the delay
            self.viewModel.selectedAsset = nil
            expectation.fulfill()
        }

        // Wait for the expectation to be fulfilled
        wait(for: [expectation], timeout: delayInSeconds + 1.0)

        // When
        viewModel.selectAsset(at: 10)

        // Then
        XCTAssertNil(viewModel.selectedAsset, "Expected no asset to be selected for an invalid index")
    }

    // MARK: - Helper Methods

    private func createMockAssets(count: Int = 20) -> [PHAsset] {
        return (0..<count).map { _ in PHAsset() }
    }
}

// MARK: - Mocks

class MockPhotoLibraryManager: PhotoLibraryManager {
    var mockedScreenshots: [PHAsset] = []
    var cachedAssets: [PHAsset] = []

    override func fetchScreenshots(completion: @escaping ([PHAsset]) -> Void) {
        completion(mockedScreenshots)
    }

    func prefetchAssets(for assets: [PHAsset], targetSize: CGSize, contentMode: PHImageContentMode, options: PHImageRequestOptions?) {
        cachedAssets = assets
    }
}
