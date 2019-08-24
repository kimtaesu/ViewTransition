//
//  ViewController.swift
//  ViewTransition
//
//  Created by tskim on 20/08/2019.
//  Copyright © 2019 hucet. All rights reserved.
//

import UIKit
import Hero

class HeroViewController: UICollectionViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Hero"
    }
}

extension HeroViewController {
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return ImageLoader.sampleImageURLs.count
    }
    
    override func collectionView(
        _ collectionView: UICollectionView,
        didEndDisplaying cell: UICollectionViewCell,
        forItemAt indexPath: IndexPath)
    {
        (cell as! ThumbnailCell).imageView.kf.cancelDownloadTask()
    }
    override func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "collectionViewCell",
            for: indexPath) as! ThumbnailCell
        cell.imageView.kf.indicatorType = .activity
        cell.imageView.hero.id = "image_\(indexPath.item)"
        cell.imageView.hero.modifiers = [.fade, .scale(0.8)]
        cell.imageView.isOpaque = true
        cell.imageView.kf.setImage(
            with: ImageLoader.sampleImageURLs[indexPath.row],
            placeholder: nil,
            options: [.transition(.fade(1)), .loadDiskFileSynchronously],
            progressBlock: { receivedSize, totalSize in
                print("\(indexPath.row + 1): \(receivedSize)/\(totalSize)")
        }
        )
        return cell
    }
    
    override func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
        ) {
        let item = ImageLoader.sampleImageURLs[indexPath.item]
        
        let vc = ImageViewController.initFromStoryboard(name: "Main")
        vc.hero.isEnabled = true
        vc.indexPath = indexPath
        self.present(vc, animated: true)
    }
}

//
//extension HeroViewController: HeroViewControllerDelegate {
//    func heroWillStartAnimatingTo(viewController: UIViewController) {
//        if let _ = viewController as? ImageViewController,
//            let index = collectionView!.indexPathsForSelectedItems?[0],
//            let cell = collectionView!.cellForItem(at: index) as? ThumbnailCell {
//            let cellPos = view.convert(cell.imageView.center, from: cell)
//            collectionView!.hero.modifiers = [.scale(3), .translate(x:view.center.x - cellPos.x, y:view.center.y + collectionView!.contentInset.top/2/3 - cellPos.y), .ignoreSubviewModifiers, .fade]
//        } else {
//            collectionView!.hero.modifiers = [.cascade]
//        }
//    }
//    
//    func heroWillStartAnimatingFrom(viewController: UIViewController) {
//        if let _ = viewController as? ImageViewController {
//            collectionView!.hero.modifiers = [.cascade]
//        } else {
//            collectionView!.hero.modifiers = [.cascade, .delay(0.2)]
//        }
//    }
//}
//
