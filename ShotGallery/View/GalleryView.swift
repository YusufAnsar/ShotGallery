//
//  GalleryView.swift
//  ShotGallery
//
//  Created by Yusuf Ansar  on 01/12/24.
//

import SwiftUI

struct GalleryView: View {
    @StateObject var viewModel = GalleryViewModel()

    var body: some View {
        VStack {
            // Preview image area
            PreviewImageView(viewModel: viewModel)
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            // Horizontal image strip for navigation
            HorizontalImageStrip(viewModel: viewModel)
                .frame(maxWidth: .infinity,maxHeight: AppConstants.Layout.horizontalImageStripHeight)
        }
        .background(AppConstants.Colors.backgroundColor.edgesIgnoringSafeArea(.all))
    }
}
