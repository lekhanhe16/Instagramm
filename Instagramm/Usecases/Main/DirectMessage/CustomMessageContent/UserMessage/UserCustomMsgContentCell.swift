//
//  UserCustomMsgContentCell.swift
//  Instagramm
//
//  Created by acupofstarbugs on 08/06/2023.
//

import MessageKit
import UIKit

class UserCustomMsgContentCell: UICollectionViewCell, BaseContentCell {
    static var reuseIdentifier: String = "usercustom"
    
    static func nib() -> UINib {
        UINib(nibName: "UserCustomMsgContentCell", bundle: nil)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    @IBOutlet var body: UILabel!

    open func configure(with message: MessageType, at indexPath: IndexPath, and messagesCollectionView: MessagesCollectionView) {
        switch message.kind {
            case .text(let txt):
                body.text = txt
            default:
                break
        }
    }
}
