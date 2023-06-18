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
    
    var status: MESS_STATUS = MESS_STATUS.SENT_SUCCEED
}

enum MESS_STATUS: Int {
    case SENT_SUCCEED = 1
    case SENT_FAILED = 0
    case RECEIVED = 2
    case READ = 3
 
}
