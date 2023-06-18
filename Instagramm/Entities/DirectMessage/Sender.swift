//
//  Sender.swift
//  Instagramm
//
//  Created by acupofstarbugs on 04/06/2023.
//

import Foundation
import MessageKit

struct Sender: SenderType{
    var senderId: String
    var isTyping = false
    var displayName: String
}
