//
//  ConversationDB.swift
//  Instagramm
//
//  Created by acupofstarbugs on 11/06/2023.
//

import FirebaseDatabase
import FirebaseFirestore
import Foundation

class ConversationDB {
    private var dbRef: DatabaseReference!
    private var fs: Firestore!
    
    static let shared = ConversationDB()
    private init() {
        dbRef = Database.database().reference()
        fs = Firestore.firestore()
    }

    func createConversation(cid: String, senders: [Sender]) {
        var data = [String: Any]()
        
        for sender in senders {
            if var senders = data["senders"] as? [String: Any] {
                senders.updateValue(["isTyping": sender.isTyping], forKey: sender.senderId)
                data["senders"] = senders
            }
            else {
                data["senders"] = [sender.senderId: ["isTyping": sender.isTyping]]
            }
        }
        
        data["cid"] = cid
        print(data)
        fs.collection("conversations").document(cid).setData(data)
    }
    
    func setIsSenderTyping(cid: String, sender: String, isTyping: Bool, completion: @escaping () -> Void) {
        fs.document("conversations/\(cid)").getDocument { docSS, _ in
            var senders = docSS?.data()!["senders"] as! [String: Any]
            let typing = (senders[sender] as! [String: Any])[
                "isTyping"
            ] as! Bool
            if typing != isTyping {
                if var s = senders[sender] as? [String: Any] {
                    s["isTyping"] = isTyping
                    senders[sender] = s
                }
                docSS?.reference.updateData(["senders": senders], completion: { error in
                    if error == nil {
                        completion()
                    }
                })
            }
        }
    }
    
    func subcribeSenderTyping(cid: String, sender: String, onSenderTyping: @escaping (Bool) -> Void) {
        fs.document("conversations/\(cid)").addSnapshotListener { ds, _ in
            if let ds, ds.exists {
                let senders = ds.data()!["senders"] as! [String: Any]
                let typing = (senders[sender] as! [String: Any])[
                    "isTyping"
                ] as! Bool
                
                onSenderTyping(typing)
            }
        }
    }
    
    func getConversations(convs: [String]) {
        for conv in convs {
            let doc = fs.collection("conversation/\(conv)").document()
            print(doc)
        }
    }
}
