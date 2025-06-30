/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
The UICollectionViewController of the sample.
*/
import UIKit

class CollectionViewController: UICollectionViewController {
    
    var dataSource: UICollectionViewDiffableDataSource<Section, Item>! = nil

    private var imageObjects = [Item]()
    
    // MARK: View
    
    private func createLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.2),
                                             heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                               heightDimension: .fractionalWidth(0.2))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize,
                                                         subitems: [item])

        let section = NSCollectionLayoutSection(group: group)

        let layout = UICollectionViewCompositionalLayout(section: section)
        return layout
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.collectionViewLayout = createLayout()
        
        let cellRegistration = UICollectionView.CellRegistration<UICollectionViewCell, Item> { (cell, indexPath, item) in
            var content = UIListContentConfiguration.cell()
            content.directionalLayoutMargins = .zero
            content.axesPreservingSuperviewLayoutMargins = []

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
        }
        
        dataSource = UICollectionViewDiffableDataSource<Section, Item>(collectionView: collectionView) {
            (collectionView: UICollectionView, indexPath: IndexPath, item: Item) -> UICollectionViewCell? in
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: item)
        }
        
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
