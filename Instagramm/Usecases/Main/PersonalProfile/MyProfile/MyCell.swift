//
//  MyCell.swift
//  Instagramm
//
//  Created by acupofstarbugs on 06/05/2023.
//

import UIKit
import Kingfisher

class MyCell: UICollectionViewCell {

    @IBOutlet weak var img: UIImageView!
    @IBOutlet weak var vieW: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func config(withPost post: Post) {
        StorageDB.shared.getImgUrlFromFirebaseStorage(url: post.media_ref[0]) { [weak self] url, error in
            if let err = error {
                print(err.localizedDescription)
            }
            else if let url = url {
                let processor = DownsamplingImageProcessor(size: CGSize(width: 400, height: 400))
                self?.img.kf.setImage(with: url, options: [.processor(processor)])
            }
        }
    }
}
