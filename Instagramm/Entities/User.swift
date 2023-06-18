//
//  User.swift
//  Instagramm
//
//  Created by acupofstarbugs on 28/05/2023.
//

import Foundation

struct User {
    var uid: String
    var followers: [String]
    var following: [String]
    var posts: [String]
    var username: String
    let user_id: String
    var direct_msgs = [String]()
}
