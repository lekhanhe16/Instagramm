//
//  MessageDB.swift
//  Instagramm
//
//  Created by acupofstarbugs on 04/06/2023.
//

import FirebaseDatabase
import FirebaseFirestore
import Foundation

class MessageDB {
    private var dbRef: DatabaseReference!
    private var fs: Firestore!
    private init() {
        dbRef = Database.database().reference()
        fs = Firestore.firestore()
    }

    static let shared = MessageDB()

    func createConversation(chatId: String, user1: String, user2: String, completion: @escaping (Bool) -> Void) {
        ConversationDB.shared.createConversation(cid: chatId, senders: [Sender(senderId: user1, displayName: ""), Sender(senderId: user2, displayName: "")])
        fs.collection("users").document(user1).getDocument { [weak self] snapshot, _ in

            if let snapshot {
                self?.insertConversation(chatId: chatId, snapshot: snapshot)
            }
        }

        fs.collection("users").document(user2).getDocument { [weak self] snapshot, _ in

            if let snapshot {
                self?.insertConversation(chatId: chatId, snapshot: snapshot)
            }
        }
    }

    func insertConversation(chatId: String, snapshot: DocumentSnapshot) {
        let data = snapshot.data()!
        var dms = data["direct_messages"] as! [String]
        dms.append(chatId)

        snapshot.reference.updateData(["direct_messages": dms])
    }

    func sendMessage(chatId: String, receiver: String, message: Message, completionHandler: @escaping (String?, Error?) -> Void) {
        var val: Any?
        switch message.kind {
            case .text(let body):
                val = body
            default: break
        }

        let value = [
            "sender": message.sender.senderId,
            "sendDate": message.sentDate.timeIntervalSince1970,
            "message": val ?? ""
        ]
        dbRef.child("direct_messages/\(chatId)")
            .childByAutoId().setValue(value) { [weak self] error, dbref in
                // print(dbref.url)
                if error != nil {
                    print(error!.localizedDescription)
                    completionHandler(nil, error!)
                }
                else {
                    if let mid = dbref.key {
                        self?.fs.document("msg_queue/\(receiver)").setData([mid: chatId], merge: true, completion: { _ in
//                            print(err?.localizedDescription)
                            self?.fs.document("msg_queue/\(message.sender.senderId)").setData([mid: chatId], merge: true, completion: { _ in
//                                print(err?.localizedDescription)
                            })
                        })

                        completionHandler(mid, nil)
                    }
                }
            }
        fs.document("conversations/\(chatId)").updateData(["latestMsg": value])
    }

    func getMessage(convid: String, mid: String, completion: @escaping (Message) -> Void) {
//        }
        dbRef.child("direct_messages/\(convid)/\(mid)").getData { _, ds in
            if let ds {
                // print(ds.ref.url)
                if let data = (ds.value as? [String: Any])?[mid] as? [String: Any] {
                    print(data)
                    let message = data["message"] as? String ?? ""
                    let sendDate = data["sendDate"] as? Double ?? 0
                    let sender = data["sender"] as? String ?? ""

                    completion(Message(sender: Sender(senderId: sender, displayName: ""), messageId: mid, sentDate: Date(timeIntervalSince1970: sendDate), kind: .text(message)))
                }
            }
        }
    }

//    func getConversation(chatId: String, handler: @escaping ([Message]) -> Void) {
//        print("getconv")
//        dbRef.child("direct_messages/\(chatId))").getData(completion:) { error, ds in
//            if error != nil {
//                print(error!.localizedDescription)
//                handler([])
//            }
//            else {
//                if let ds, let conv = ds.value as? [String: Any] {
//                    var res = [Message]()
//                    for msg in conv {
//                        let value = msg.value as! [String: Any]
//                        let id = value["sender"] as! String
//                        let sendDate = value["sendDate"] as! Double
//                        let mess = value["message"] as! String
//                        let mes = Message(sender: Sender(senderId: id, displayName: ""),
//                                          messageId: msg.key,
//                                          sentDate: Date(timeIntervalSince1970: sendDate),
//                                          kind: .text(mess))
    ////                        print(mes)
//                        res.append(mes)
//                    }
//                    handler(res)
//                }
//            }
//        }
//    }

    func subcribeToNewMsg(chatId: String, handler: @escaping ([Message]) -> Void) {
        dbRef.child("direct_messages/\(chatId)").observe(.childAdded) { ds in
//            print(ds)
            if let value = ds.value as? [String: Any] {
                var res = [Message]()
                let id = value["sender"] as! String
                let sendDate = value["sendDate"] as! Double
                let mess = value["message"] as! String
                let mes = Message(sender: Sender(senderId: id, displayName: ""),
                                  messageId: ds.key,
                                  sentDate: Date(timeIntervalSince1970: sendDate),
                                  kind: .text(mess))
//                print(mes)
                res.append(mes)
                handler(res)
            }
        }
    }
}
