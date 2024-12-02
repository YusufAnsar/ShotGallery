//
//  PreviewImageView.swift
//  ShotGallery
//
//  Created by Yusuf Ansar  on 01/12/24.
//

import SwiftUI
import Photos

struct PreviewImageView: View {
    @ObservedObject var viewModel: GalleryViewModel
    @State private var loadedImage: UIImage? = nil

    var body: some View {
        ZStack {
            Color.black.opacity(0.8).edgesIgnoringSafeArea(.all)
            if let selectedAsset = viewModel.selectedAsset {
                if let image = loadedImage {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .clipped()
                        .cornerRadius(10)
                        .padding()
                } else {
                    ProgressView()
                        .onAppear {
                            loadImage(for: selectedAsset)
                        }
                }
            } else {
                Text("No image selected")
                    .foregroundColor(.gray)
            }
        }
        .onChange(of: viewModel.selectedAsset) { newAsset in
            self.loadedImage = nil
            if let asset = newAsset {
                loadImage(for: asset)
            }
        }
    }

    private func loadImage(for asset: PHAsset) {
        ImageLoader.loadFullImage(for: asset) { image in
            DispatchQueue.main.async {
                self.loadedImage = image
            }
        }
    }
}
