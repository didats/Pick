//
//  PickerViewDelegateProxy.swift
//  Pick
//
//  Created by suguru-kishimoto on 2017/09/08.
//  Copyright © 2017年 Suguru Kishimoto. All rights reserved.
//

import UIKit

final class PickerViewDelegateProxy: NSObject, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    public var options: PickerOptions {
        didSet {
            beforeLimitedState = false
        }
    }

    var reloadCellsHandler: (UICollectionView, IndexPath) -> Void = { _, _ in }
    var didSelectHandler: () -> Void = {}
    var didDeselectHandler: () -> Void = {}

    private var beforeLimitedState: Bool = false
    init(options: PickerOptions) {
        self.options = options
        super.init()
    }

    private func _collectionView(_ collectionView: UICollectionView) -> PickerCollectionView {
        return collectionView as! PickerCollectionView
    }

    private func isLimited(collectionView: UICollectionView) -> Bool {
        return _collectionView(collectionView).orderedIndexPathsForSelectedItems.count >= self.options.limitOfSelection
    }

    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        if collectionView.allowsMultipleSelection {
            return !isLimited(collectionView: collectionView)
        }
        return true
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let isLimited = self.isLimited(collectionView: collectionView)
        defer {
            beforeLimitedState = isLimited
        }

        _collectionView(collectionView).orderedIndexPathsForSelectedItems.append(indexPath)

        if collectionView.allowsMultipleSelection {
            if beforeLimitedState != isLimited, isLimited {
                collectionView.indexPathsForVisibleItems.forEach { reloadCellsHandler(collectionView, $0) }
            }
        }
        didSelectHandler()
    }

    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let isLimited = self.isLimited(collectionView: collectionView)
        defer {
            beforeLimitedState = isLimited
        }

        if let index = _collectionView(collectionView).orderedIndexPathsForSelectedItems.index(of: indexPath) {
            _collectionView(collectionView).orderedIndexPathsForSelectedItems.remove(at: index)
        }

        if collectionView.allowsMultipleSelection {
            if beforeLimitedState != isLimited, !isLimited {
                collectionView.indexPathsForVisibleItems.forEach { reloadCellsHandler(collectionView, $0) }
            }
        }
        didDeselectHandler()
    }

    private var margin: CGFloat {
        let numberOfColumnsInRow: CGFloat = CGFloat(self.options.numberOfColumnsInRow)
        return UIScreen.main.bounds.width.truncatingRemainder(dividingBy: numberOfColumnsInRow) == 0 ? 1 : 1.5
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return margin
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return margin
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let numberOfColumnsInRow: CGFloat = CGFloat(self.options.numberOfColumnsInRow)
        let spacing: CGFloat = margin * (numberOfColumnsInRow - 1)
        let side: CGFloat = (UIScreen.main.bounds.width - spacing) / numberOfColumnsInRow
        return CGSize(width: side, height: side)
    }
}
