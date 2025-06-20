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
class Item: Identifiable {

    var image: UIImage!
    var isImageLoaded: Bool = false
    let url: URL!
    let id = UUID()

    init(image: UIImage, url: URL) {
        self.image = image
        self.url = url
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
