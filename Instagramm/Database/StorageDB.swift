//
//  StorageDB.swift
//  Instagramm
//
//  Created by acupofstarbugs on 08/05/2023.
//

import Foundation
import FirebaseStorage

class StorageDB {
    static let shared = StorageDB()
    private init() {
        dbRef = Storage.storage().reference()
    }
    
    private var dbRef: StorageReference!
    
    func getImgUrlFromFirebaseStorage(url: String, completion: @escaping (URL?, Error?) -> Void) {
        dbRef.child(url).downloadURL { url, error in
            if error != nil {
                completion(nil, error)
            }
            else {
                completion (url, nil)
            }
        }
    }
}
