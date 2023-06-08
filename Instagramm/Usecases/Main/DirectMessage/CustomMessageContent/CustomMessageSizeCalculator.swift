//
//  CustomMessageSizeCalculator.swift
//  Instagramm
//
//  Created by acupofstarbugs on 06/06/2023.
//

import Foundation
import MessageKit

open class CustomMessageSizeCalculator: MessageSizeCalculator {
    override open func messageContainerSize(for message: MessageType) -> CGSize {
        // Customize this function implementation to size your content appropriately. This example simply returns a constant size
        // Refer to the default MessageKit cell implementations, and the Example App to see how to size a custom cell dynamically

        var txt = ""
        switch message.kind {
            case .text(let text):

                txt = text
            default:
                break
        }
//        let sz = txt.size(withAttributes: [
//            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 17)
//        ])
//        let cellWidth = (sz.width < 250) ? sz.width : 250
//        let labelString = NSAttributedString(string: txt, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 17.0)])
//        let cellRect = labelString.boundingRect(with: CGSize(width: cellWidth, height: CGFloat.greatestFiniteMagnitude), options: NSStringDrawingOptions.usesLineFragmentOrigin, context: nil)
//
//        return CGSize(width: cellWidth, height: cellRect.size.height)
        let sz = txt.size(withAttributes: [
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 17)
        ])
//        print(abs(sz.width - UIScreen.main.bounds.width) / 300)
        let lines = (abs(sz.width - UIScreen.main.bounds.width) / 300)
        let rt = CGSize(width: (sz.width < 300) ? sz.width : 300, height: (sz.width >= 300) ?
                        35 * CGFloat(abs(sz.width - UIScreen.main.bounds.width) / 300 + 1) : 35)
//         print(rt)
        return rt
    }

    func heightForLabel(text: String, font: UIFont, width: CGFloat) -> CGFloat {
        var label: UILabel! = UILabel(frame: CGRectMake(0, 0, width, CGFloat.greatestFiniteMagnitude))
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.font = font
        label.text = text

        label.sizeToFit()
        let height = label.frame.height
        label = nil
        return height
    }
}
