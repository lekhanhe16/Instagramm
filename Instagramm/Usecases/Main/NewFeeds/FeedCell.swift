//
//  FeedCell.swift
//  Instagramm
//
//  Created by acupofstarbugs on 07/05/2023.
//

import UIKit

class FeedCell: UICollectionViewCell {

    var mediaUrls = [String]()
    var postId: String!
    @IBOutlet weak var mediaCollection: UICollectionView!
    @IBOutlet weak var lblCaption: UILabel!
    @IBOutlet weak var lblUser: UILabel!
    
    @IBOutlet weak var btnLikePost: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        
        mediaCollection.showsVerticalScrollIndicator = false
        mediaCollection.showsHorizontalScrollIndicator = false
        mediaCollection.collectionViewLayout = layout
        mediaCollection.register(UINib(nibName: "MediaViewCell", bundle: nil), forCellWithReuseIdentifier: "mediacell")
        mediaCollection.delegate = self
        mediaCollection.dataSource = self
        lblCaption.sizeToFit()
    }

    func didLikePost(like: Bool) {
        if like {
            btnLikePost.tintColor = .systemRed
        }
        else {
            btnLikePost.tintColor = .label
        }
    }
    func loadMedia(withMedia: [String]) {
        if mediaUrls.count == 0 {
            mediaUrls = withMedia
            DispatchQueue.main.async { [weak self] in
                self?.mediaCollection.reloadData()
            }
        }
    }
    
    
    @IBAction func btnLikePostClick(_ sender: UIButton) {
//        btnLikePost.tintColor = .red
        let userid = UserDB.shared.getCurrentUser(uid: "")!.user_id
        if sender.tintColor != .systemRed {
            PostDB.shared.likePost(postId: postId, userId: userid) { isSucceed in
                if isSucceed {
                    sender.tintColor = .systemRed
                }
            }
        }
        else {
            PostDB.shared.unLikePost(postId: postId, userId: userid) { isSucceed in
                if isSucceed {
                    sender.tintColor = .label
                }
            }
        }
    }
}

extension FeedCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return mediaUrls.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "mediacell", for: indexPath) as! MediaViewCell
        cell.setImg(url: mediaUrls[indexPath.row])
        return cell
    }
    
}

extension FeedCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.frame.width, height: 300)
    }
}
