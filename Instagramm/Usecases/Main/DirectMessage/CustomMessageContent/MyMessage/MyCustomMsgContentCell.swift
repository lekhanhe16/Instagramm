//
//  CustomMsgContentCell.swift
//  Instagramm
//
//  Created by acupofstarbugs on 07/06/2023.
//

import MessageKit
import UIKit

class MyCustomMsgContentCell: UICollectionViewCell, BaseContentCell {
    static var reuseIdentifier: String = "mycustom"
    
    static func nib() -> UINib {
        UINib(nibName: "MyCustomMsgContentCell", bundle: nil)
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
