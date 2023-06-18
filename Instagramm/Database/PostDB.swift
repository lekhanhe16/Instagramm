//
//  PostDB.swift
//  Instagramm
//
//  Created by acupofstarbugs on 07/05/2023.
//

import FirebaseDatabase
import FirebaseFirestore
import FirebaseStorage
import Foundation

class PostDB {
    static let shared = PostDB()
    private init() {
        fs = Firestore.firestore()
        dbRef = Database.database().reference()
        storageRef = Storage.storage().reference()
    }

    var fetchedPosts = Set<String>()

    private var fs: Firestore!
    private var storageRef: StorageReference!
    private var dbRef: DatabaseReference!
    private var lastVisible: DocumentSnapshot?
    
    func likePost(postId: String, userId: String, handler: @escaping (Bool) -> Void) {
        fs.collection("posts").document(postId).getDocument { ds, err in
            if err != nil {
                
            }
            else {
                if let dataSnapshot = ds {
                    var likes = dataSnapshot.get("likes") as! [String]
                    if !likes.contains(userId) {
                        likes.append(userId)
                    }
                    dataSnapshot.reference.updateData([
                        "likes": likes
                    ]) { error in
                        if error != nil {
                            handler(false)
                        }
                        else {
                            handler(true)
                        }
                    }
                }
            }
        }
    }
    
    func unLikePost(postId: String, userId: String, handler: @escaping (Bool) -> Void) {
        fs.collection("posts").document(postId).getDocument { ds, err in
            if err != nil {
                
            }
            else {
                if let dataSnapshot = ds {
                    var likes = dataSnapshot.get("likes") as! [String]
                    likes.removeAll(where: {$0 == userId})
                    dataSnapshot.reference.updateData([
                        "likes": likes
                    ]) { error in
                        if error != nil {
                            handler(false)
                        }
                        else {
                            handler(true)
                        }
                    }
                }
            }
        }
    }
    
    func fetchPersonalPosts(of userId: String, completion: @escaping ([Post]) -> Void) {
        var listUser = [String]()
        listUser.append(userId)
        fs.collection("posts")
            .order(by: "post_date", descending: true)
            .whereField("author", isEqualTo: userId)
            .getDocuments { qs, _ in
                if let qs {
                    var result = [Post]()
                    for doc in qs.documents {
                        result.append(Post(post_id: doc.documentID, post_date: doc["post_date"] as! Double, author: doc["author"] as! String, caption: doc["caption"] as! String, likes: (doc["likes"] as? [String]) ?? [], media_ref: doc["media_ref"] as! [String]))
                    }
                    completion(result)
                }
                else {
                    completion([])
                }
            }
    }
        
    func fetchNewFeeds(completion: @escaping ([Post]) -> Void) {
        var listUser = [String]()
        
        for user_id in UserDB.shared.getCurrentUser(uid: "")!.following {
            listUser.append(user_id)
        }
        
        listUser.append(UserDB.shared.getCurrentUser(uid: "")!.user_id)
//        print(listUser)
        if let lastvisible = lastVisible {
            print(lastvisible.documentID)
            
            fs.collection("posts")
                .order(by: "post_date", descending: true)
                .whereField("author", in: listUser)
                .start(afterDocument: lastvisible)
                .limit(to: 25).getDocuments { [weak self] qs, _ in
                    if let qs {
                        self?.lastVisible = qs.documents.last
                        
                        var result = [Post]()
                            
                        for doc in qs.documents {
                            if !(self?.fetchedPosts.contains(doc.documentID))! {
                                result.append(Post(post_id: doc.documentID, post_date: doc["post_date"] as! Double, author: doc["author"] as! String, caption: doc["caption"] as! String, likes: (doc["likes"] as? [String]) ?? [], media_ref: doc["media_ref"] as! [String]))
                                self?.fetchedPosts.insert(doc.documentID)
                            }
                        }
                            
                        completion(result)
                    }
                    else {
                        completion([])
                    }
                }
        }
        else {
            fs.collection("posts")
                .order(by: "post_date", descending: true)
                .whereField("author", in: listUser)
                .limit(to: 25).getDocuments { [weak self] qs, _ in
                    if let qs {
                        self?.lastVisible = qs.documents.last
                        var result = [Post]()
                        
                        for doc in qs.documents {
                            self?.fetchedPosts.insert(doc.documentID)
                            result.append(Post(post_id: doc.documentID, post_date: doc["post_date"] as! Double, author: doc["author"] as! String, caption: doc["caption"] as! String, likes: (doc["likes"] as? [String]) ?? [], media_ref: doc["media_ref"] as! [String]))
                        }
                        completion(result)
                    }
                    else {
                        completion([])
                    }
                }
        }
    }
    
    func uploadMediaPost(images: [[String: Any]], postCaption: String, completion: @escaping (Bool) -> Void) {
        
        var postMediaRefs = [String]()
        
        let newDoc = fs.collection("posts").document()
        let newId = newDoc.documentID
        for img in images {
            postMediaRefs.append("media/posts/\(newId)/\(img["file_name"] as! String)")
        }
        let user = UserDB.shared.getCurrentUser(uid: "")!.user_id
        
//        Database.database().reference().child("post_comments").child(newId).setValue([String:Any]())

        dbRef.child("post_comments/\(newId)").childByAutoId().setValue([String : Any]()) { err, ref in
            if let err = err {
                print(err.localizedDescription)
            }
            else {
//                print(ref.)
            }
        }
        
        let newPost = [
            "media_ref": postMediaRefs,
            "caption": postCaption,
            "likes": [String](),
            "author": user,
//            "post_id": newId,
            "post_date": Date().timeIntervalSince1970
        ] as [String: Any]
        
        newDoc.setData(newPost) { [weak self] error in
            if error == nil {
                for img in images {
                    self?.storageRef.child("media/posts/\(newId)/\(img["file_name"] as! String)").putData((img["img"] as! UIImage).jpegData(compressionQuality: 0.75)!) { _, error in
                        if let err = error {
                            print(err.localizedDescription)
                        }
                    }
                }
                
                self?.fs.collection("users").document(user).getDocument { snapshot, error in
                    if let snapshot {
                        var posts = snapshot["posts"] as! [String]
                        posts.append(newId)
                        snapshot.reference.updateData(["posts": posts]) { error in
                            if error == nil {
                                completion(true)
                            }
                        }
                    }
                }
            }
            else {
                completion(false)
            }
        }
    }
}
