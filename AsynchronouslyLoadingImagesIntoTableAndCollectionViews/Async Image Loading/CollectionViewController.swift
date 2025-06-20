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
        }

        dataSource = UICollectionViewDiffableDataSource<Section, Item>(collectionView: collectionView) {
            (collectionView: UICollectionView, indexPath: IndexPath, item: Item) -> UICollectionViewCell? in
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: item)
        }
        
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
