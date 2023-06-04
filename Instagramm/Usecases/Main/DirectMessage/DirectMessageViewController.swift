//
//  DirectMessageViewController.swift
//  Instagramm
//
//  Created by  on 04/06/2023.
//

import InputBarAccessoryView
import MessageKit
import UIKit

class DirectMessageViewController: MessagesViewController {
    var curSender: Sender!
    var jack = Sender(senderId: "1234", displayName: "Jack")
    var ben = Sender(senderId: "321", displayName: "Ben")
    var receiver: String!
    var messages = [Message]()
    override func viewDidLoad() {
        super.viewDidLoad()
        curSender = Sender(senderId: UserDB.shared.getCurrentUser()?.user_id ?? "", displayName: UserDB.shared.getCurrentUser()?.username ?? "")
        // Do any additional setup after loading the view.
//        getConversation()
        subcribeToNewMessage()
        setUpMessagesCollectionView()
    }
    
    func getConversation() {
        // Mock
//        messages.append(Message(sender: curSender, messageId: "2", sentDate: Date().addingTimeInterval(-80009), kind: .text("hello")))
//        messages.append(Message(sender: jack, messageId: "2", sentDate: Date().addingTimeInterval(-70000), kind: .text("hello khanh")))
//        messages.append(Message(sender: jack, messageId: "2", sentDate: Date().addingTimeInterval(-60000), kind: .text("how are you")))
        
        
        MessageDB.shared.getConversation(chatId: genChatId(re: receiver, se: curSender.senderId)) {
            [weak self] conv in
            if !conv.isEmpty {
                self?.messages.append(contentsOf: conv)
                DispatchQueue.main.async {
                    self?.messagesCollectionView.reloadData()
                    self?.messagesCollectionView.scrollToBottom(animated: false)
                }
            }
        }
    }
    
    func subcribeToNewMessage() {
        MessageDB.shared.subcribeToNewMsg(chatId: genChatId(re: receiver, se: curSender.senderId)) { [weak self] conv in
            if !conv.isEmpty {
                self?.messages.append(contentsOf: conv)
                self?.messages.sort(by: { m1, m2 in
                    m1.sentDate.timeIntervalSince1970 < m2.sentDate.timeIntervalSince1970
                })
                DispatchQueue.main.async {
                    self?.messagesCollectionView.reloadData()
                    self?.messagesCollectionView.scrollToBottom(animated: false)
                }
            }
        }
    }
    func genChatId(re: String, se: String) -> String {
        if re > se {
            return "\(re)\(se)"
        }
        return "\(se)\(re)"
    }
    
    func setUpMessagesCollectionView() {
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messageInputBar.delegate = self
        if let layout = messagesCollectionView.collectionViewLayout as? MessagesCollectionViewFlowLayout {
            layout.setMessageOutgoingAvatarSize(CGSize(width: 16, height: 16))
            layout.setMessageIncomingAvatarSize(CGSize(width: 16, height: 16))
        }
        //        messagesCollectionView.layer.setAffineTransform(CGAffineTransform(rotationAngle: -.pi))
    }
}

extension DirectMessageViewController: InputBarAccessoryViewDelegate {
    
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        let newMessage = Message(sender: curSender, messageId: "", sentDate: .now, kind: .text(text))
        MessageDB.shared.sendMessage(chatId: genChatId(re: receiver, se: curSender.senderId), message: newMessage) { messId, error in
            if error != nil {}
            else {
                inputBar.inputTextView.text = ""
            }
        }
    }
}

extension DirectMessageViewController: MessagesDataSource {
    func currentSender() -> MessageKit.SenderType {
        curSender
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessageKit.MessagesCollectionView) -> MessageKit.MessageType {
        messages[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessageKit.MessagesCollectionView) -> Int {
        messages.count
    }
    
    func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
        if message.sender.senderId != curSender.senderId {
            return .bubbleTail(.bottomLeft, .pointedEdge)
        }
        return .bubbleTail(.bottomRight, .pointedEdge)
    }
}

extension DirectMessageViewController: MessagesLayoutDelegate {
    
}

extension DirectMessageViewController: MessagesDisplayDelegate {
    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        if indexPath.section + 1 < messages.count, messages[indexPath.section + 1].sender.senderId == messages[indexPath.section].sender.senderId {
            avatarView.isHidden = true
        }
    }
}
