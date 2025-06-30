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
    let imageURL: URL
    let id = UUID()
    var image: UIImage?

    init(imageURL: URL) {
        self.imageURL = imageURL
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
            return Item(imageURL: URL(string: "https://www.jacobvanorder.com/async-Image-loading/images/UIImage_\(index).png")!)
        }
    }
}
