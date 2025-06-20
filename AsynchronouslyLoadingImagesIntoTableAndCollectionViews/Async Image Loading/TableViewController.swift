/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
The UITableViewController of the sample.
*/
import UIKit

class TableViewController: UITableViewController {
    
    var dataSource: UITableViewDiffableDataSource<Section, Item>! = nil

    private var imageObjects = [Item]()
    
    // MARK: View
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource = UITableViewDiffableDataSource<Section, Item>(tableView: tableView) {
            (tableView: UITableView, indexPath: IndexPath, item: Item) -> UITableViewCell? in
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            /// - Tag: update
            var content = cell.defaultContentConfiguration()
            if !item.isImageLoaded {
                Task { [weak self] in
                    let newImage: UIImage
                    do {
                        newImage = try await ImageCache.publicCache.load(url: item.url)
                    } catch {
                        newImage = ImageCache.publicCache.brokenImage
                    }
                    guard let self else { return }
                    var updatedSnapshot = self.dataSource.snapshot()
                    item.image = newImage
                    item.isImageLoaded = true
                    updatedSnapshot.reloadItems([item])
                    await self.dataSource.apply(updatedSnapshot, animatingDifferences: true)
                }
            }
            content.image = item.image
            cell.contentConfiguration = content
            return cell
        }
        
        self.dataSource.defaultRowAnimation = .fade
        
        // Get our image URLs for processing.
        if imageObjects.isEmpty {
                for index in 1...100 {
                    if let url = Bundle.main.url(forResource: "UIImage_\(index)", withExtension: "png") {
                        self.imageObjects.append(Item(image: ImageCache.publicCache.placeholderImage, url: url))
                    }
                }
                var initialSnapshot = NSDiffableDataSourceSnapshot<Section, Item>()
                initialSnapshot.appendSections([.main])
                initialSnapshot.appendItems(self.imageObjects)
                self.dataSource.apply(initialSnapshot, animatingDifferences: true)
        }
    }
    
}

