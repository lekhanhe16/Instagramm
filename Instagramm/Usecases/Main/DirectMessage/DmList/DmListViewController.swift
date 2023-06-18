//
//  DmListViewController.swift
//  Instagramm
//
//  Created by acupofstarbugs on 08/06/2023.
//

import UIKit

class DmListViewController: UIViewController {
    var conversation = [Conversation]()
    @IBOutlet weak var dmCollectionView: UICollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
}

extension DmListViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        conversation.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "", for: indexPath)
        return cell
    }
    
    
}

extension DmListViewController: UICollectionViewDelegate {
    
}
