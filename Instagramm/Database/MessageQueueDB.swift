//
//  MessageQueueDB.swift
//  Instagramm
//
//  Created by acupofstarbugs on 19/06/2023.
//

import FirebaseDatabase
import FirebaseFirestore
import Foundation

class MessageQueueDB {
    static let shared = MessageQueueDB()
    private var dbRef: DatabaseReference!
    private var fs: Firestore!
    private var msgQueueListener: ListenerRegistration!
    private init() {
        dbRef = Database.database().reference()
        fs = Firestore.firestore()
    }

    func addMessageQueueListener(handler: @escaping ((String, String)) -> Void) {
        
        msgQueueListener = fs.document("msg_queue/\(UserDB.shared.getCurrentUser()!.user_id)")
            .addSnapshotListener { ds, error in
                
                if let ds = ds, let data = ds.data() {
//                    print(type(of: data))
                    for key in data.keys {
                        //print("\(key) \(data[key] as! String)")
                        print("new message")
                        handler((key, data[key] as! String))
                        
                    }
                    ds.reference.delete()
                }
                
            }
    }
    
    func removeMessageQueueListener() {
        msgQueueListener.remove()
    }
}
