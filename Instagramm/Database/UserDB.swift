//
//  UserDB.swift
//  Instagramm
//
//  Created by acupofstarbugs on 05/05/2023.
//

import FirebaseFirestore
import Foundation
import FirebaseAuth

class UserDB {
    private init() {}

    static let shared = UserDB()
    private var curUser: [String: Any]?
    private let db = Firestore.firestore()
    
    func isUsernameValid(username: String, handler: @escaping (Bool) -> Void) {
        db.collection("users").getDocuments { querySnapshot, error in
            if error != nil {
                return
            }
            print(username)
            if let querySnapshot {
                if querySnapshot.documents.first(where: { $0.get("username") != nil && ($0.get("username") as! String) == username }) == nil {
                    handler(true)
                }
                else {
                    handler(false)
                }
            }
            else {
                handler(false)
            }
        }
    }

    func exeUnFollowing(follower: String, following: String) {
        db.collection("users").getDocuments { querySnapshot, _ in
            if let qs = querySnapshot {
                let followingUser = qs.documents.first { qds in
                    qds.documentID == following
                }
                var followers = followingUser?.get("followers") as! [String]
                followers.removeAll { $0 == follower }
                followingUser?.reference.updateData(["followers": followers])
                
                let followerUser = qs.documents.first { qds in
                    qds.documentID == follower
                }
                var followings = followerUser?.get("following") as! [String]
                followings.removeAll { $0 == following }
                followerUser?.reference.updateData(["following": followings])
            }
        }
    }
    
    func getUserByUserID(id: String, completion: @escaping ([String:Any]?) -> Void) {
        db.collection("users").document(id).getDocument { ds, err in
            if err != nil {
                completion(nil)
            }
            else if let doc = ds {
                completion([
                    "username": doc.get("username") as! String,
                    "uid": doc.get("uid") as! String,
                    "followers": doc.get("followers") as! [String],
                    "following": doc.get("following") as! [String],
                    "posts": doc.get("posts") as! [String],
                    "user_id": doc.documentID
                ])
            }
        }
    }
    func exeFollowing(follower: String, following: String) {
        db.collection("users").getDocuments { querySnapshot, _ in
            if let qs = querySnapshot {
                let followingUser = qs.documents.first { qds in
                    qds.documentID == following
                }
                var followers = followingUser?.get("followers") as! [String]
                followers.append(follower)
                followingUser?.reference.updateData(["followers": followers])
                
                let followerUser = qs.documents.first { qds in
                    qds.documentID == follower
                }
                var followings = followerUser?.get("following") as! [String]
                followings.append(following)
                followerUser?.reference.updateData(["following": followings])
            }
        }
    }

    func searchForUsersWithName(withName: String, handler: @escaping ([[String: Any]]?, Error?) -> Void) {
        db.collection("users").getDocuments { [weak self] querySnapshot, error in
            if error != nil {
                handler(nil, error)
            }
            if let querySnapshot {
                var result = [[String: Any]]()
                for doc in querySnapshot.documents {
                    if let username = doc.get("username") as? String, username.contains(withName), username != self?.curUser!["username"] as! String {
                        result.append([
                            "username": doc.get("username") as! String,
                            "uid": doc.get("uid") as! String,
                            "followers": doc.get("followers") as! [String],
                            "following": doc.get("following") as! [String],
                            "posts": doc.get("posts") as! [String],
                            "user_id": doc.documentID
                        ])
                    }
                }
                handler(result, nil)
            }
            else {
                handler(nil, nil)
            }
        }
    }

    func signUpNewUser(username: String, uid: String) {
        db.collection("users").addDocument(data: [
            "username": username,
            "uid": uid,
            "followers": [],
            "following": [],
            "posts": []
        ])
    }

    func setCurrentUser(user: [String: Any]) {
        curUser = user
    }

    func getCurrentUser(uid: String) -> [String: Any]? {
        return curUser
    }
    
    func getCurrentUserAsync(completion: @escaping () -> Void) {
        print("hello")
        db.collection("users").getDocuments { [weak self] querySnapshot, _ in
            if let querySnapshot {
                let doc = querySnapshot.documents.first(where: { $0.get("username") != nil && ($0.get("uid") as! String) == Auth.auth().currentUser?.uid})!
                    
                self?.curUser = [
                    "username": doc.get("username") as! String,
                    "uid": doc.get("uid") as! String,
                    "followers": doc.get("followers") as! [String],
                    "following": doc.get("following") as! [String],
                    "posts": doc.get("posts") as! [String],
                    "user_id": doc.documentID
                ]
                completion()
            }
        }
    }
}
