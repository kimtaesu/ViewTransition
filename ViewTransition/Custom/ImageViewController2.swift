//
//  ImageViewController2.swift
//  ViewTransition
//
//  Created by tskim on 20/08/2019.
//  Copyright © 2019 hucet. All rights reserved.
//

import UIKit

class CustomImageViewController: UIViewController, StoryboardInitializable {
    
    @IBOutlet weak var imageView: UIImageView!
    var indexPath: IndexPath!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.kf.setImage(with: ImageLoader.sampleImageURLs[indexPath.item])
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(pan)))
    }
    @objc func pan(panGR: UIPanGestureRecognizer) {
        let translation = panGR.translation(in: nil)
        let progress = translation.y / 2 / view.bounds.height
        switch panGR.state {
        case .began: break
//            hero.dismissViewController()
        case .changed:
            break
//            Hero.shared.update(progress)
//            let currentPos = CGPoint(x: translation.x + view.center.x, y: translation.y + view.center.y)
//            Hero.shared.apply(modifiers: [.position(currentPos)], to: imageView)
        default: break
//            if progress + panGR.velocity(in: nil).y / view.bounds.height > 0.3 {
//                Hero.shared.finish()
//            } else {
//                Hero.shared.cancel()
//            }
        }
    }
}
