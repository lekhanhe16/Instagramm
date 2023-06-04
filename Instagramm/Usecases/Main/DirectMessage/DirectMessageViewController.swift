//
//  DirectMessageViewController.swift
//  Instagramm
//
//  Created by  on 04/06/2023.
//

import UIKit
import MessageKit

class DirectMessageViewController: MessagesViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
       
        // Do any additional setup after loading the view.
        
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
}


extension DirectMessageViewController: MessagesDataSource {
    func currentSender() -> MessageKit.SenderType {
        <#code#>
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessageKit.MessagesCollectionView) -> MessageKit.MessageType {
        <#code#>
    }
    
    func numberOfSections(in messagesCollectionView: MessageKit.MessagesCollectionView) -> Int {
        <#code#>
    }
    
    
}

extension DirectMessageViewController: MessagesLayoutDelegate {
    
}

extension DirectMessageViewController: MessagesDisplayDelegate {
    
}

