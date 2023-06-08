//
//  BaseContentCell.swift
//  Instagramm
//
//  Created by acupofstarbugs on 07/06/2023.
//

import Foundation
import UIKit.UINib
import MessageKit

protocol BaseContentCell: UICollectionViewCell {
    static var reuseIdentifier: String {get}
    static func nib() -> UINib
    func configure(with message: MessageType, at indexPath: IndexPath, and messagesCollectionView: MessagesCollectionView)
}
