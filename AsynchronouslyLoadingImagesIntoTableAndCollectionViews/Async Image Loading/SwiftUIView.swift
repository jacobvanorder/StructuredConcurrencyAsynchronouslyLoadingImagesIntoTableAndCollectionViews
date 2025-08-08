//
//  SwiftUIView.swift
//  Async Image Loading
//
//  Created by Jacob Van Order on 7/21/25.
//  Copyright © 2025 Not Apple. All rights reserved.
//

import UIKit
import SwiftUI

struct SwiftUIView: View {

    let items: [Item]
    private let columns = [GridItem](repeating: GridItem(.flexible(), spacing: 0), count: 5)

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 0) {
                ForEach(items) { item in
                    ItemView(item: item)
                }
            }
        }
    }

    // Subview

    private struct ItemView: View {
        static let imageCacheActor: ImageCacheActor = ImageCacheActor.publicCache
        let item: Item
        @State private var image: UIImage?

        var body: some View {
            if let image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(1, contentMode: .fit)
            } else {
                Image(uiImage: ImageCacheActor.placeholderImage)
                    .resizable()
                    .aspectRatio(1, contentMode: .fill)
                    .scaleEffect(0.5)
                    .task {
                        do {
                            self.image = try await Self.imageCacheActor.load(imageAtURL: item.imageURL)
                        } catch {
                            self.image = UIImage(systemName: "wifi.slash")
                        }
                    }
            }
        }
    }
}

#Preview {
    SwiftUIView(items: Item.mockItems)
}
