//
//  CollectionLayoutProvider.swift
//  IdChallenge
//
//  Created by Abbas Sabeti on 18.09.24.
//

import UIKit

final class CollectionViewLayoutProvider {
    static let shared = CollectionViewLayoutProvider()
    
    func createLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { (sectionIndex, layoutEnvironment) -> NSCollectionLayoutSection? in
            let itemSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(0.333),
                heightDimension: .fractionalHeight(1.0)
            )
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            item.contentInsets = NSDirectionalEdgeInsets(
                top: 5,
                leading: 5,
                bottom: 5,
                trailing: 5
            )
            
            let groupSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .absolute(230)
            )
            let items = Array(repeating: item, count: 3)
            let group = NSCollectionLayoutGroup.horizontal(
                layoutSize: groupSize,
                subitems: items
            )
            
            let section = NSCollectionLayoutSection(group: group)

            section.orthogonalScrollingBehavior = .none
            section.interGroupSpacing = 10
            
            return section
        }
        return layout
    }
}
