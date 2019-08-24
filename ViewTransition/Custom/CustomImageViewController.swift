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
        imageView.transitionId = "image_\(indexPath.item)"
        print("CustomImageViewController viewDidLoad \(imageView.frame)")
        imageView.kf.setImage(with: ImageLoader.sampleImageURLs[indexPath.item])
    }
}

