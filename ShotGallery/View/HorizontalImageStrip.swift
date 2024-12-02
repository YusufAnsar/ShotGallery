//
//  HorizontalImageStrip.swift
//  ShotGallery
//
//  Created by Yusuf Ansar on 01/12/24.
//

import SwiftUI
import Photos

struct HorizontalImageStrip: View {
    // MARK: - Properties

    @ObservedObject var viewModel: GalleryViewModel
    @State private var scrollViewProxy: ScrollViewProxy?
    @State private var containerWidth: CGFloat = 0
    @State private var scrollOffset: CGFloat = 0

    // MARK: - Constants

    private enum Constants {
        static let backgroundColor = Color.black.opacity(0.8)
        static let thumbnailSpacing: CGFloat = 10
        static let scaleEffect: CGFloat = 1.2
        static let animationResponse: CGFloat = 0.3
        static let animationDampingFraction: CGFloat = 0.6
        static let prefetchRange: Int = 5
        static let selectionThreshold: CGFloat = 20
    }

    // MARK: - Body

    var body: some View {
        VStack {
            Spacer()

            GeometryReader { geometry in
                ScrollViewReader { proxy in
                    ScrollView(.horizontal, showsIndicators: false) {
                        LazyHStack(spacing: Constants.thumbnailSpacing) {
                            ForEach(viewModel.screenshots.indices, id: \.self) { index in
                                thumbnailView(for: index, in: geometry, with: proxy)
                            }
                        }
                        .padding(.horizontal, (containerWidth / 2) - AppConstants.Layout.thumbnailViewSize.width / 2)
                        .background(geometryReaderBackground(proxy: proxy))
                    }
                }
            }
            .frame(height: AppConstants.Layout.horizontalImageStripHeight)
            .background(Constants.backgroundColor)
            .onAppear {
                if let previewIndex = viewModel.previewIndex {
                    scrollToSelected(proxy: scrollViewProxy, index: previewIndex)
                }
            }
        }
    }

    // MARK: - Private Methods

    /// Creates a thumbnail view for a given index.
    private func thumbnailView(for index: Int, in geometry: GeometryProxy, with proxy: ScrollViewProxy) -> some View {
        ThumbnailView(asset: viewModel.screenshots[index], isSelected: index == viewModel.previewIndex)
            .frame(
                width: AppConstants.Layout.thumbnailViewSize.width,
                height: AppConstants.Layout.thumbnailViewSize.height
            )
            .scaleEffect(index == viewModel.previewIndex ? Constants.scaleEffect : 1.0)
            .animation(
                .spring(
                    response: Constants.animationResponse,
                    dampingFraction: Constants.animationDampingFraction
                ),
                value: viewModel.selectedAsset
            )
            .onAppear {
                viewModel.prefetchAssets(
                    in: max(0, index - Constants.prefetchRange)..<min(viewModel.screenshots.count, index + Constants.prefetchRange)
                )
            }
            .onTapGesture {
                viewModel.selectAsset(at: index)
                scrollToSelected(proxy: proxy, index: index)
            }
            .background(thumbnailGeometryBackground(for: index, in: geometry))
    }

    /// Handles background updates for the thumbnail geometry.
    private func thumbnailGeometryBackground(for index: Int, in geometry: GeometryProxy) -> some View {
        GeometryReader { thumbnailGeometry in
            Color.clear
                .onAppear {
                    containerWidth = geometry.size.width
                }
                .onChange(of: scrollOffset) { _ in
                    updateSelectionIfNeeded(
                        thumbnailGeometry: thumbnailGeometry,
                        index: index,
                        containerWidth: geometry.size.width
                    )
                }
        }
    }

    /// Adds a background using GeometryReader for the scroll view.
    private func geometryReaderBackground(proxy: ScrollViewProxy) -> some View {
        GeometryReader { geo in
            Color.clear
                .onAppear {
                    scrollViewProxy = proxy
                }
                .onChange(of: geo.frame(in: .global).origin.x) { newOffset in
                    scrollOffset = newOffset
                }
        }
    }

    /// Scrolls the view to the selected index.
    private func scrollToSelected(proxy: ScrollViewProxy?, index: Int) {
        withAnimation {
            proxy?.scrollTo(index, anchor: .center)
        }
    }

    /// Updates the selection if the thumbnail is near the center.
    private func updateSelectionIfNeeded(thumbnailGeometry: GeometryProxy, index: Int, containerWidth: CGFloat) {
        let centerThreshold = containerWidth / 2
        let thumbnailCenter = thumbnailGeometry.frame(in: .global).midX
        if abs(thumbnailCenter - centerThreshold) < Constants.selectionThreshold {
            viewModel.selectAsset(at: index)
        }
    }
}
