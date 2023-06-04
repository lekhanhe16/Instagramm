//
//  Message.swift
//  Instagramm
//
//  Created by acupofstarbugs on 04/06/2023.
//

import Foundation
import MessageKit

struct Message: MessageType {
    var sender: MessageKit.SenderType
    
    var messageId: String
    
    var sentDate: Date
    
    var kind: MessageKit.MessageKind
}
