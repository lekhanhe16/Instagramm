//
//  MediaViewCell.swift
//  Instagramm
//
//  Created by acupofstarbugs on 08/05/2023.
//

import UIKit
import Kingfisher

class MediaViewCell: UICollectionViewCell {

    @IBOutlet weak var media: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func setImg(url: String) {
        StorageDB.shared.getImgUrlFromFirebaseStorage(url: url) { [weak self] url, err in
            if let err = err {
                print(err.localizedDescription)
            }
            else if let url = url {
                let processor = DownsamplingImageProcessor(size: CGSize(width: 400, height: 400))
                self?.media.kf.setImage(with: url, options: [.processor(processor)])
            }
        }
    }
}
