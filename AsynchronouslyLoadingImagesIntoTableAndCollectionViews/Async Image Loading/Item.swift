/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
A model Item for displaying images.
*/
import UIKit

enum Section {
    case main
}

@MainActor
final class Item: Identifiable {
    let imageName: String
    let id = UUID()
    var image: UIImage?

    init(imageName: String) {
        self.imageName = imageName
    }
}

extension Item: Hashable, Equatable {
    nonisolated func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    nonisolated static func == (lhs: Item, rhs: Item) -> Bool {
        return lhs.id == rhs.id
    }
}

extension Item {
    static var mockItems: [Item] {
        return Array(1...100).compactMap { index in
            return Item(imageName: "UIImage_\(index).png")
        }
    }
}
