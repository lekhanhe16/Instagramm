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
        curSender = Sender(senderId: UserDB.shared.getCurrentUser()?.user_id ?? "", displayName: UserDB.shared.getCurrentUser()?.username ?? "")
        subcribeToNewMessage()
        setUpMessagesCollectionView()
        super.viewDidLoad()

        // Do any additional setup after loading the view.
//        getConversation()
    }

//    func getConversation() {
//        // Mock
    ////        messages.append(Message(sender: curSender, messageId: "2", sentDate: Date().addingTimeInterval(-80009), kind: .text("hello")))
    ////        messages.append(Message(sender: jack, messageId: "2", sentDate: Date().addingTimeInterval(-70000), kind: .text("hello khanh")))
    ////        messages.append(Message(sender: jack, messageId: "2", sentDate: Date().addingTimeInterval(-60000), kind: .text("how are you")))
//
//        MessageDB.shared.getConversation(chatId: genChatId(re: receiver, se: curSender.senderId)) {
//            [weak self] conv in
//            if !conv.isEmpty {
//                self?.messages.append(contentsOf: conv)
//                DispatchQueue.main.async {
//                    self?.messagesCollectionView.reloadData()
//                    self?.messagesCollectionView.scrollToBottom(animated: false)
//                }
//            }
//        }
//    }

    func subcribeToNewMessage() {
        MessageDB.shared.subcribeToNewMsg(chatId: genChatId(re: receiver, se: curSender.senderId)) { [weak self] conv in
            if !conv.isEmpty {
                self?.messages.append(contentsOf: conv)
                self?.messages.sort(by: { m1, m2 in
                    m1.sentDate.timeIntervalSince1970 > m2.sentDate.timeIntervalSince1970
                })
                DispatchQueue.main.async {
                    self?.messagesCollectionView.reloadData()
//                    self?.messagesCollectionView.scrollToBottom(animated: false)
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
        messagesCollectionView = MessagesCollectionView(frame: .zero, collectionViewLayout: CustomMessagesFlowLayout())

//        messagesCollectionView.register(CustomMsgContentCell.self)
//        messagesCollectionView.bounces = false
        messagesCollectionView.register(MyCustomMsgContentCell.nib(), forCellWithReuseIdentifier: MyCustomMsgContentCell.reuseIdentifier)
        messagesCollectionView.register(UserCustomMsgContentCell.nib(), forCellWithReuseIdentifier: UserCustomMsgContentCell.reuseIdentifier)
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
//        messagesCollectionView.messagesDisplayDelegate = self
//        messagesCollectionView.delegate = self
        messagesCollectionView.messageCellDelegate = self
        messageInputBar.delegate = self
        if let layout = messagesCollectionView.collectionViewLayout as? MessagesCollectionViewFlowLayout {
            layout.setMessageOutgoingAvatarSize(CGSize(width: 16, height: 16))
            layout.setMessageIncomingAvatarSize(CGSize(width: 16, height: 16))
        }
        messagesCollectionView.layer.setAffineTransform(CGAffineTransform(rotationAngle: -.pi))
    }

//    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        var txt = ""
//        switch messages[indexPath.section].kind {
//            case .text(let text):
//
//                txt = text
//            default:
//                break
//        }
//        let sz = txt.size(withAttributes: [
//            NSAttributedString.Key.font : UIFont.systemFont(ofSize: 17)
//        ])
//        print(NSAttributedString(string: txt).boundingRect(with: CGSizeMake((sz.width < 150) ? sz.width : 150, 300), context: nil).width)
//        return sz
//    }
    override open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let messagesDataSource = messagesCollectionView.messagesDataSource else {
            fatalError("Ouch. nil data source for messages")
        }
        // before checking the messages check if section is reserved for typing otherwise it will cause IndexOutOfBounds error
        if isSectionReservedForTypingIndicator(indexPath.section) {
            return super.collectionView(collectionView, cellForItemAt: indexPath)
        }
        let message = messagesDataSource.messageForItem(at: indexPath, in: messagesCollectionView)
//        print(message)
//        if case .text = message.kind {

        switch message.sender.senderId {
            case curSender.senderId:
                let my = dequeueRegisteredCell(collectionView: messagesCollectionView, msg: message, indexPath: indexPath, reuseIdentifier: MyCustomMsgContentCell.reuseIdentifier) as! MyCustomMsgContentCell
                my.configure(with: message, at: indexPath, and: messagesCollectionView)
                my.layer.setAffineTransform(CGAffineTransform(rotationAngle: .pi))
                return my
            default:
                let user = dequeueRegisteredCell(collectionView: messagesCollectionView, msg: message, indexPath: indexPath, reuseIdentifier: UserCustomMsgContentCell.reuseIdentifier) as! UserCustomMsgContentCell
                user.configure(with: message, at: indexPath, and: messagesCollectionView)
                user.layer.setAffineTransform(CGAffineTransform(rotationAngle: .pi))
                return user
        }

//            cell.layer.setAffineTransform(CGAffineTransform(rotationAngle: .pi))

//        }
//        return super.collectionView(collectionView, cellForItemAt: indexPath)
    }

    func dequeueRegisteredCell(collectionView: MessagesCollectionView, msg: MessageType, indexPath: IndexPath, reuseIdentifier: String) -> UICollectionViewCell {
        collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
    }
}

extension DirectMessageViewController: MessageCellDelegate {}

extension DirectMessageViewController: InputBarAccessoryViewDelegate {
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        let newMessage = Message(sender: curSender, messageId: "", sentDate: .now, kind: .text(text))
        MessageDB.shared.sendMessage(chatId: genChatId(re: receiver, se: curSender.senderId), message: newMessage) { _, error in
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

//
extension DirectMessageViewController: MessagesLayoutDelegate {}

// extension DirectMessageViewController: MessagesDisplayDelegate {
//    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
//        if indexPath.section + 1 < messages.count, messages[indexPath.section + 1].sender.senderId == messages[indexPath.section].sender.senderId {
//            avatarView.isHidden = true
//        }
//    }
// }
