//
//  Comment.swift
//  Instagramm
//
//  Created by acupofstarbugs on 04/06/2023.
//

import Foundation

class Comment {
    var userId: String
    var userName: String
    var body: String
    var time: Double
    var replyTo: Comment!
    var isParent = true
    
    init(uid: String, name: String, body: String, time: Double, replyTo: Comment?) {
        userId = uid
        userName = name
        self.body = body
        self.time = time
        self.replyTo = replyTo
        if let rep = self.replyTo {
            isParent = false
        }
    }
}
