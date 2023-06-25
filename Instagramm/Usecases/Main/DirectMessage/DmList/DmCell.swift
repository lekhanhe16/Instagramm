//
//  DmCell.swift
//  Instagramm
//
//  Created by acupofstarbugs on 08/06/2023.
//

import UIKit

class DmCell: UICollectionViewCell, BaseContentCell {
    @IBOutlet var latestMsg: UILabel!
    @IBOutlet var chatWithLbl: UILabel!
    static var reuseIdentifier: String = "DmCell"

    static func nib() -> UINib {
        UINib(nibName: "DmCell", bundle: nil)
    }

    func configure(with latestMess: Message?, receiver: String) {
        
        guard let lm = latestMess else { return }
        chatWithLbl.text = receiver
        switch lm.kind {
            case .text(let msg):
                latestMsg.text = msg
            default:
                break
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
}
