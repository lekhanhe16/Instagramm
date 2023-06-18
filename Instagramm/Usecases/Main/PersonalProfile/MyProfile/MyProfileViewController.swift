//
//  MyProfileViewController.swift
//  Instagramm
//
//  Created by acupofstarbugs on 05/05/2023.
//

import UIKit
import FirebaseAuth
class MyProfileViewController: UIViewController {

    var dataSet1 = [Post]()
    let dataSet2 = ["brown", "cyan"]
    
    @IBOutlet weak var nPosts: UILabel!
    @IBOutlet weak var nFollowing: UILabel!
    @IBOutlet weak var nFollowers: UILabel!
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var lblUsername: UILabel!
    
    @IBAction func btnLogoutClick(_ sender: UIButton) {
        try! Auth.auth().signOut()
    }
    @IBAction func segmentValueChanged(_ sender: UISegmentedControl) {
        let index = sender.selectedSegmentIndex
        switch index {
            case 0:
                snapShot.deleteItems(dataSet2)
                snapShot.appendItems(dataSet1.compactMap {$0.post_id}, toSection: 0)
                dataSource.apply(snapShot)
            default:
//                snapShot.deleteItems(dataSet1.compactMap {$0["post_id"] as? String})
//                snapShot.appendItems(dataSet2, toSection: 1)
//                dataSource.apply(snapShot)
                return
                
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        nPosts.text = "\(UserDB.shared.getCurrentUser(uid: "")!.posts.count)"
        nFollowers.text = "\(UserDB.shared.getCurrentUser(uid: "")!.followers.count)"
        nFollowing.text = "\(UserDB.shared.getCurrentUser(uid: "")!.following.count)"
    }
    var dataSource: UICollectionViewDiffableDataSource<Int, String>!
    var snapShot: NSDiffableDataSourceSnapshot<Int, String>!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.collectionViewLayout = getCollectionViewLayout()
        collectionView.register(UINib(nibName: "MyCell", bundle: nil), forCellWithReuseIdentifier: "mycell")
        
        createDataSource()
        
        PostDB.shared.fetchPersonalPosts(of: UserDB.shared.getCurrentUser(uid: "")!.user_id) { [weak self] myPosts in
            if  myPosts.isEmpty == false {
                self?.dataSet1 = myPosts
                self?.loadData1()
            }
        }
//        loadData()
    }
    
    func loadData1() {
        print(dataSet1.compactMap {$0.post_id})
        snapShot = NSDiffableDataSourceSnapshot()
        snapShot.appendSections([0])
        snapShot.appendItems(dataSet1.compactMap {$0.post_id}, toSection: 0)
        dataSource.apply(snapShot)
    }
    
    func createDataSource() {
        dataSource = UICollectionViewDiffableDataSource(collectionView: collectionView) { [weak self] collectionView,indexPath,item in
            if indexPath.section == 0 {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "mycell", for: indexPath) as! MyCell
                cell.config(withPost: (self?.dataSet1.first(where: { post in
                    post.post_id == item
                })!)!)
                return cell
            }
            else {
                return nil
            }
        }
    }
    
    func getCollectionViewLayout() -> UICollectionViewLayout {
        return UICollectionViewCompositionalLayout { [weak self] sectionIndex,layoutEnv in
            switch sectionIndex {
                case 0:
                    return self?.getPostsSection()
                default:
                    return self?.getReelsSection()
            }
        }
    }
    
    func getPostsSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1/3), heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 5, trailing: 5)
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalWidth(1/3))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        return NSCollectionLayoutSection(group: group)
    }

    func getReelsSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1/2), heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5)
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalWidth(1/2))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        return NSCollectionLayoutSection(group: group)
    }
}
