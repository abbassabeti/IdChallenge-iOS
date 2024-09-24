//
//  GalleryViewController.swift
//  IdChallenge
//
//  Created by Abbas Sabeti on 18.09.24.
//

import UIKit
import Combine

final class GalleryViewController: UIViewController {

    private enum Section {
        case main
    }

    var collectionView: UICollectionView!
    private var dataSource: UICollectionViewDiffableDataSource<Section, UIImage>!
    private let interactor: GalleryInteracting

    init(interactor: GalleryInteracting) {
        self.interactor = interactor
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        setupViews()
        let images = interactor.provideImages()
        updateSnapshot(with: images)
    }
    
    private func setupViews() {
        collectionView = UICollectionView(
            frame: view.bounds,
            collectionViewLayout: CollectionViewLayoutProvider.shared.createLayout()
        )
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.backgroundColor = .systemBackground
        view.addSubview(collectionView)
        
        collectionView.register(
            GalleryImageCell.self,
            forCellWithReuseIdentifier: GalleryImageCell.reuseIdentifier
        )
        configureDataSource()
    }

    private func configureDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Section, UIImage>(
            collectionView: collectionView
        ) { (collectionView, indexPath, image) -> UICollectionViewCell? in
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: GalleryImageCell.reuseIdentifier,
                for: indexPath
            ) as! GalleryImageCell
            cell.configure(with: image)
            return cell
        }
    }
    
    private func updateSnapshot(with images: [UIImage]) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, UIImage>()
        snapshot.appendSections([.main])
        snapshot.appendItems(images, toSection: .main)
        dataSource.apply(snapshot, animatingDifferences: true)
    }
}
