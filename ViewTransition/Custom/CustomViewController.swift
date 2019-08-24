//
//  CustomViewController.swift
//  ViewTransition
//
//  Created by tskim on 20/08/2019.
//  Copyright © 2019 hucet. All rights reserved.
//

import UIKit

class CustomViewController: UICollectionViewController {

    var fadeTransition: TransitioningDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Custom"
    }
}

extension CustomViewController {
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
        let vc = CustomImageViewController.initFromStoryboard(name: "Main")
        vc.modalPresentationStyle = .custom
        let dismissAnimator = SourceDismissAnimator(with: collectionView, for: indexPath, id: "image_\(indexPath.item)")
        let uiPresentation = UIInteractablePresentationController(presentedViewController: vc, presenting: self)
        fadeTransition = TransitioningDelegate(
            presentTransition: SourcePresentAnimator(with: collectionView, for: indexPath, id: "image_\(indexPath.item)"),
            dismissTransition: dismissAnimator,
//            dismissInteraction: InteractivePercentDrivenTransition(gesture: uiPresentation.panGestureRecognizer, presented: vc),
            dismissInteraction: InteractiveTransition(gesture: uiPresentation.panGestureRecognizer, animator: dismissAnimator, presented: vc),
            presentationController: uiPresentation
        )
        vc.transitioningDelegate = fadeTransition
        vc.modalPresentationStyle = .custom
        self.navigationController?.delegate = fadeTransition
        vc.indexPath = indexPath

        self.present(vc, animated: true)
    }
}
