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

            if let itemImage = item.image { // Did we set the image previously?
                content.image = itemImage
            } else if let cachedImage = ImageCacheActor.publicCache.cachedImage(atURL: item.imageURL) { // Did the actor already load this image elsewhere?
                content.image = cachedImage
            } else { // Set the placeholder and go fetch the image!
                content.image = ImageCacheActor.placeholderImage
                Task { [weak self] in
                    let newImage: UIImage
                    do {
                        newImage = try await ImageCacheActor.publicCache.load(imageAtURL: item.imageURL)
                    } catch {
                        newImage = ImageCacheActor.brokenImage
                    }
                    guard let self else { return }
                    item.image = newImage
                    var updatedSnapshot = self.dataSource.snapshot()
                    updatedSnapshot.reloadItems([item])
                    await self.dataSource.apply(updatedSnapshot, animatingDifferences: true)
                }
            }

            cell.contentConfiguration = content
            return cell
        }
        
        self.dataSource.defaultRowAnimation = .fade
        
        // Get our image URLs for processing.
        if imageObjects.isEmpty {
            self.imageObjects = Item.mockItems
            var initialSnapshot = NSDiffableDataSourceSnapshot<Section, Item>()
            initialSnapshot.appendSections([.main])
            initialSnapshot.appendItems(self.imageObjects)
            self.dataSource.apply(initialSnapshot, animatingDifferences: true)
        }
    }
    
}

