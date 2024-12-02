//
//  GalleryViewModel.swift
//  ShotGallery
//
//  Created by Yusuf Ansar on 01/12/24.
//

import SwiftUI
import Photos

/// ViewModel for managing and displaying gallery data.
final class GalleryViewModel: ObservableObject {

    // MARK: - Constants

    enum Constants {
        static let initialPrefetchRange: Range<Int> = 0..<10
    }

    // MARK: - Published Properties

    /// The array of screenshot assets fetched from the photo library.
    @Published private(set) var screenshots: [PHAsset] = []

    /// The currently selected screenshot asset.
    @Published var selectedAsset: PHAsset?

    /// The index of the currently selected asset in the screenshots array.
    var previewIndex: Int? {
        guard let selectedAsset else { return nil }
        return screenshots.firstIndex(of: selectedAsset)
    }

    // MARK: - Private Properties

    private let cachingManager = PHCachingImageManager()
    private var previousPrefetchRange: Range<Int> = Constants.initialPrefetchRange
    private let photoLibraryManager: PhotoLibraryManager

    // MARK: - Initialization

    init(photoLibraryManager: PhotoLibraryManager = PhotoLibraryManager()) {
        self.photoLibraryManager = photoLibraryManager
        loadScreenshots()
    }

    // MARK: - Public Methods

    /// Selects a screenshot asset at the specified index.
    /// - Parameter index: The index of the asset to select.
    func selectAsset(at index: Int) {
        guard screenshots.indices.contains(index) else { return }
        selectedAsset = screenshots[index]
    }

    /// Prefetches assets within the specified range to optimize scrolling performance.
    /// - Parameter range: The range of indices to prefetch.
    func prefetchAssets(in range: Range<Int>) {
        guard !screenshots.isEmpty else { return }

        let toCache = Array(screenshots[range])
        let toStopCaching = Array(screenshots[previousPrefetchRange])

        cachingManager.startCachingImages(for: toCache,
                                          targetSize: AppConstants.Layout.thumbnailImageSize,
                                          contentMode: .aspectFill,
                                          options: nil)
        cachingManager.stopCachingImages(for: toStopCaching,
                                         targetSize: AppConstants.Layout.thumbnailImageSize,
                                         contentMode: .aspectFill,
                                         options: nil)

        previousPrefetchRange = range
    }

    /// Loads screenshots from the photo library and sets the initial selection.
    func loadScreenshots() {
        photoLibraryManager.fetchScreenshots { [weak self] screenshots in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.screenshots = screenshots
                // Start caching initial visible range
                // self.prefetchAssets(in: Constants.initialPrefetchRange)
                self.selectAsset(at: 0)
            }
        }
    }
}
