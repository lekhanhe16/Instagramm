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
        //print(data)
        fs.collection("conversations").document(cid).setData(data)
    }
    
    func setIsSenderTyping(cid: String, sender: String, isTyping: Bool, completion: @escaping () -> Void) {
        fs.document("conversations/\(cid)").getDocument { docSS, _ in
            if var senders = docSS?.data()?["senders"] as? [String:Any]{
                
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
            else {
                completion()
            }
        }
    }
    
    func subcribeSenderTyping(cid: String, sender: String, onSenderTyping: @escaping (Bool) -> Void) {
        fs.document("conversations/\(cid)").addSnapshotListener { ds, _ in
            if let ds, ds.exists, let senders = ds.data()?["senders"] as? [String: Any] {
                
                let typing = (senders[sender] as! [String: Any])[
                    "isTyping"
                ] as! Bool
                
                onSenderTyping(typing)
            }
        }
    }
    
    func getConversations(convs: [String], completion: @escaping ([Conversation]) -> Void) {
        var conversations = [Conversation]()
        
        DispatchQueue.global(qos: .userInitiated).async { [unowned self] in
            let group = DispatchGroup()
            for conv in convs {
                group.enter()
                let doc = fs.document("conversations/\(conv)")
                
                doc.getDocument(completion: { ds, _ in
                    if let data = ds?.data() {
                        var cnv = Conversation(senders: [Sender](), convID: "")
                        let senders = data["senders"] as? [String: Any]
                        if let senders, senders.isEmpty == false {
                            for key in senders.keys {
                                let isTyping = (senders[key] as! [String: Any])["isTyping"] as! Bool
                                cnv.senders.append(Sender(senderId: key, isTyping: isTyping, displayName: ""))
                            }
                        }
                        if let lm = data["latestMsg"] as? [String:Any] {
                            cnv.latestMsg = Message(sender: Sender(senderId: lm["sender"] as! String, displayName: ""), messageId: "", sentDate: Date(timeIntervalSince1970: lm["sendDate"] as! Double), kind: .text(lm["message"] as! String))
                        }
                        cnv.convID = data["cid"] as! String
                        conversations.append(cnv)
                    }
                    group.leave()
                })
                group.wait()
            }
            conversations.sort { a, b in
                let timeA = a.latestMsg?.sentDate.timeIntervalSince1970 ?? 0
                let timeB = b.latestMsg?.sentDate.timeIntervalSince1970 ?? 0
                return timeA > timeB
            }
            completion(conversations)
        }
    }
    
    func getConvUpdated() {
        
    }
}
