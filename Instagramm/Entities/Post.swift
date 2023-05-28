//
//  Post.swift
//  Instagramm
//
//  Created by acupofstarbugs on 28/05/2023.
//

import Foundation

struct Post {
    let post_id: String
    let post_date: Double
    let author: String
    var caption: String
    var likes: [String]
    var media_ref: [String]
}
