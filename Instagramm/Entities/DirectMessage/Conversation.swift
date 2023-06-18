//
//  Conversion.swift
//  Instagramm
//
//  Created by acupofstarbugs on 09/06/2023.
//

import Foundation

struct Conversation {
    var senders: [Sender]
    var messages = [Message]()
    var convID: String
}
