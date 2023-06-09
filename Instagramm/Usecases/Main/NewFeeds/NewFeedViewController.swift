//
//  HomeViewController.swift
//  Instagramm
//
//  Created by acupofstarbugs on 05/05/2023.
//

import UIKit

class NewFeedViewController: UIViewController {
    var posts = [Post]()
    var isFetching = false
    @IBAction func btnHeartClicked(_ sender: UIBarButtonItem) {
        navigationController?.navigationBar.isHidden = true
    }

    @IBOutlet var newFeeds: UICollectionView!
    override func loadView() {
        super.loadView()
    }

    @IBAction func btnDirectMsgClicked(_ sender: Any) {
        let dmVc = UIStoryboard(name: "DmList", bundle: nil).instantiateViewController(withIdentifier: "dmlistVC") as! DmListViewController
        dmVc.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(dmVc, animated: true)
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        setUpNewFeeds()
        UserDB.shared.getCurrentUserAsync {
            PostDB.shared.fetchNewFeeds { [weak self] posts in
                self?.posts = posts
                DispatchQueue.main.async { [weak self] in
                    self?.newFeeds.reloadData()
                }
            }
        }
    }

    func setUpNewFeeds() {
        newFeeds.register(UINib(nibName: "FeedCell", bundle: nil), forCellWithReuseIdentifier: "feedcell")
        newFeeds.collectionViewLayout = UICollectionViewFlowLayout()
        newFeeds.delegate = self
        newFeeds.dataSource = self
        newFeeds.alwaysBounceVertical = true
    }
}

extension NewFeedViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        posts.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "feedcell", for: indexPath) as! FeedCell
        cell.lblUser.text = posts[indexPath.row].author
        cell.postId = posts[indexPath.row].post_id
        cell.didLikePost(like: (posts[indexPath.row].likes.contains(UserDB.shared.getCurrentUser(uid: "")!.user_id)))
        cell.lblCaption.text = posts[indexPath.row].caption
        cell.loadMedia(withMedia: posts[indexPath.row].media_ref)
        return cell
    }
}

extension NewFeedViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        CGSize(width: view.frame.width, height: view.frame.height * 0.65)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y + scrollView.frame.size.height > newFeeds.contentSize.height + 50{
            print("fetch new")
            if !isFetching {
                isFetching = true
                PostDB.shared.fetchNewFeeds { posts in
                    if !posts.isEmpty {
                        DispatchQueue.main.asyncAfter(deadline: .now()+2){ [weak self] in
                            self?.posts.append(contentsOf: posts)
                            self?.newFeeds.reloadData()
                            self?.isFetching = false
                        }
                    }
                }
            }
        }
    }
}
