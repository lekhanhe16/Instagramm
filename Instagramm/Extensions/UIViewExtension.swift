//
//  UIViewExtension.swift
//  Instagramm
//
//  Created by acupofstarbugs on 06/05/2023.
//

import Foundation
import UIKit

extension UIView {
    func left() ->CGFloat {
        return frame.origin.x
    }
    func right() ->CGFloat {
        return frame.origin.x + frame.width
    }
    func top() ->CGFloat {
        return frame.origin.y
    }
    func bottom() ->CGFloat {
        return frame.origin.y + frame.height
    }
}
