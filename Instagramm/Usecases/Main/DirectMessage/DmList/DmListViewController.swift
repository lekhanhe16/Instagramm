//
//  DmListViewController.swift
//  Instagramm
//
//  Created by acupofstarbugs on 08/06/2023.
//

import UIKit

class DmListViewController: UIViewController {
    var conversations = [Conversation]()
    @IBOutlet var dmCollectionView: UICollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupCollectionView()
        ConversationDB.shared.getConversations(convs: UserDB.shared.getCurrentUser()?.direct_msgs ?? []) { [weak self] convs in
            self?.conversations = convs
            DispatchQueue.main.async {
                self?.dmCollectionView.reloadData()
            }
        }

        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        MessageQueueDB.shared.addMessageQueueListener { [weak self] tuple in
            let mid = tuple.0
            let conv_id = tuple.1

            MessageDB.shared.getMessage(convid: conv_id, mid: mid) { msg in
                print("\(msg) \(conv_id)")
                for (ind, conv) in self?.conversations.enumerated() ?? [Conversation]().enumerated() {
                    print("\(conv) **")
                    if conv.convID == conv_id, conv.latestMsg?.sentDate.compare(msg.sentDate) == .orderedAscending {
                        var conve = conv
                        print(conve)
                        conve.latestMsg = msg
                        self?.conversations.remove(at: ind)
                        self?.conversations.insert(conve, at: 0)
                        
                        print(self?.conversations)
                        DispatchQueue.main.async {
                            self?.dmCollectionView.reloadData()
                        }
                    }
                }
            }
        }
        
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        dmCollectionView.reloadData()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        MessageQueueDB.shared.removeMessageQueueListener()
    }
    func setupCollectionView() {
//        var config = UICollectionLayoutListConfiguration(appearance: .plain)
//        config.showsSeparators = false
//
//        let layout = UICollectionViewCompositionalLayout.list(using: config)
//        dmCollectionView.collectionViewLayout = layout

        dmCollectionView.register(UINib(nibName: "DmCell", bundle: nil), forCellWithReuseIdentifier: "dmcell")
        dmCollectionView.delegate = self
        dmCollectionView.dataSource = self
    }
}

extension DmListViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        CGSize(width: collectionView.frame.width, height: 70)
    }
}

extension DmListViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        conversations.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "dmcell", for: indexPath) as! DmCell
        cell.configure(with: conversations[indexPath.row].latestMsg, receiver: getReceiver(indexPath: indexPath))
        return cell
    }
}

extension DmListViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let dmVC = UIStoryboard(name: "DirectMessage", bundle: nil)
            .instantiateViewController(withIdentifier: "DMVC") as! DirectMessageViewController
        dmVC.receiver = getReceiver(indexPath: indexPath)
        navigationController?.pushViewController(dmVC, animated: true)
    }
}

extension DmListViewController {
    func getReceiver(indexPath: IndexPath) -> String {
        conversations[indexPath.row].senders.filter { $0.senderId != UserDB.shared.getCurrentUser()?.user_id }[0].senderId
    }
}
