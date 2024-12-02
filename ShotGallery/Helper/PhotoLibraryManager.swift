//
//  PhotoLibraryManager.swift
//  ShotGallery
//
//  Created by Yusuf Ansar on 01/12/24.
//

import Photos
import Combine

/// Manages access and fetching of screenshots from the user's photo library.
class PhotoLibraryManager {

    // MARK: - Properties

    /// Contains all fetched screenshot assets.
    private(set) var screenshots: [PHAsset] = []

    // MARK: - Public Methods

    /// Fetches screenshots from the photo library and updates the `screenshots` array.
    func fetchScreenshots(completion: @escaping ([PHAsset]) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            let fetchOptions = self.createFetchOptions()
            let fetchedAssets = PHAsset.fetchAssets(with: .image, options: fetchOptions)

            var tempScreenshots: [PHAsset] = []
            fetchedAssets.enumerateObjects { asset, _, _ in
                tempScreenshots.append(asset)
            }

            DispatchQueue.main.async {
                self.screenshots = tempScreenshots
                completion(self.screenshots)
            }
        }
    }

    // MARK: - Private Methods

    /// Creates the fetch options for retrieving screenshots.
    /// - Returns: A configured `PHFetchOptions` instance.
    private func createFetchOptions() -> PHFetchOptions {
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "mediaSubtype == %d", PHAssetMediaSubtype.photoScreenshot.rawValue)
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        return fetchOptions
    }
}
