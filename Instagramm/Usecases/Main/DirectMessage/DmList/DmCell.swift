//
//  DmCell.swift
//  Instagramm
//
//  Created by acupofstarbugs on 08/06/2023.
//

import UIKit

class DmCell: UICollectionViewCell, BaseContentCell {
    @IBOutlet weak var latestMsg: UILabel!
    @IBOutlet weak var chatWithLbl: UILabel!
    static var reuseIdentifier: String = "DmCell"
    
    static func nib() -> UINib {
        UINib(nibName: "DmCell", bundle: nil)
    }
    
    func configure(with: Conversation) {
        
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
