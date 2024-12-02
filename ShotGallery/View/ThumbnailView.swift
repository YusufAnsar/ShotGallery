//
//  ThumbnailView.swift
//  ShotGallery
//
//  Created by Yusuf Ansar on 01/12/24.
//

import SwiftUI
import Photos

/// A view displaying a thumbnail image for a given PHAsset.
struct ThumbnailView: View {
    // MARK: - Properties
    let asset: PHAsset
    let isSelected: Bool

    @State private var thumbnail: UIImage?

    // MARK: - Constants
    private enum Constants {
        static let borderWidth: CGFloat = 3
        static let placeholderColor: Color = .gray.opacity(0.3)
        static let selectedBorderColor: Color = .blue
        static let unselectedBorderColor: Color = .clear
    }

    // MARK: - Body
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Thumbnail or Placeholder
                if let image = thumbnail {
                    thumbnailImage(image: image, size: geometry.size)
                } else {
                    placeholderView(size: geometry.size)
                }
            }
            .onAppear {
                loadThumbnail(targetSize: geometry.size)
            }
        }
        .frame(
            width: AppConstants.Layout.thumbnailImageSize.width,
            height: AppConstants.Layout.thumbnailImageSize.height
        )
        .border(
            isSelected ? Constants.selectedBorderColor : Constants.unselectedBorderColor,
            width: Constants.borderWidth
        )
    }

    // MARK: - Private Methods

    /// Loads the thumbnail image for the provided PHAsset.
    /// - Parameter targetSize: The target size for the thumbnail.
    private func loadThumbnail(targetSize: CGSize) {
        ImageLoader.loadThumbnail(for: asset, targetSize: targetSize) { image in
            DispatchQueue.main.async {
                self.thumbnail = image
            }
        }
    }

    /// Creates a thumbnail image view.
    /// - Parameters:
    ///   - image: The `UIImage` to display.
    ///   - size: The size of the thumbnail.
    /// - Returns: A `View` displaying the image.
    private func thumbnailImage(image: UIImage, size: CGSize) -> some View {
        Image(uiImage: image)
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: size.width, height: size.height)
            .clipped()
    }

    /// Creates a placeholder view when the thumbnail is not yet loaded.
    /// - Parameter size: The size of the placeholder.
    /// - Returns: A `View` displaying the placeholder.
    private func placeholderView(size: CGSize) -> some View {
        Constants.placeholderColor
            .frame(width: size.width, height: size.height)
            .overlay(ProgressView())
    }
}
