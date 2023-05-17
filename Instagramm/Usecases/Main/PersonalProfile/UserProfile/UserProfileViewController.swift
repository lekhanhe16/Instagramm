//
//  UserProfileViewController.swift
//  Instagramm
//
//  Created by acupofstarbugs on 05/05/2023.
//

import UIKit

class UserProfileViewController: UIViewController {
    let FOLLOW = "Follow"
    let UNFOLLOW = "Unfollow"
    
    var dataSet1 = [[String: Any]]()
    let dataSet2 = ["brown", "cyan"]
    
    @IBOutlet weak var numOfPost: UILabel!
    @IBOutlet weak var numOfFollowers: UILabel!
    @IBOutlet weak var numOfFollowing: UILabel!
    
    
    @IBOutlet weak var collectionView: UICollectionView!
    let follower = UserDB.shared.getCurrentUser(uid: "")!["user_id"] as! String
    @IBOutlet weak var btnFollow: UIButton!
    var following = ""
    var user: [String:Any]!
    init?(coder: NSCoder, user: [String: Any]) {
        super.init(coder: coder)
        self.user = user
        following = user["user_id"] as! String
    }
    
    var dataSource: UICollectionViewDiffableDataSource<Int, String>!
    var snapShot: NSDiffableDataSourceSnapshot<Int, String>!
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UserDB.shared.getUserByUserID(id: user["user_id"] as! String) { [weak self] result in
            if let result = result {
                self?.user = result
                self?.setUpView()
            }
        }
        
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.collectionViewLayout = getCollectionViewLayout()
        collectionView.register(UINib(nibName: "MyCell", bundle: nil), forCellWithReuseIdentifier: "mycell")
        
        createDataSource()
        
        PostDB.shared.fetchPersonalPosts(of: user!["user_id"] as! String) { [weak self] myPosts in
            if  myPosts.isEmpty == false {
                self?.dataSet1 = myPosts
                self?.loadData1()
            }
        }
        
    }

    func loadData1() {
        print(dataSet1.compactMap {$0["post_id"] as? String})
        snapShot = NSDiffableDataSourceSnapshot()
        snapShot.appendSections([0])
        snapShot.appendItems(dataSet1.compactMap {$0["post_id"] as? String}, toSection: 0)
        dataSource.apply(snapShot)
    }
    
    func createDataSource() {
        dataSource = UICollectionViewDiffableDataSource(collectionView: collectionView) { [weak self] collectionView,indexPath,item in
            if indexPath.section == 0 {
                print("hellooo")
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "mycell", for: indexPath) as! MyCell
                cell.config(withPost: (self?.dataSet1.first(where: { post in
                    (post["post_id"] as! String) == item
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
    
    func setUpView() {
        title = user["username"] as? String
        // Do any additional setup after loading the view.
        print(user["followers"] as! [String])
        if (user["followers"] as! [String]).contains(follower) {
            btnFollow.setTitle(UNFOLLOW, for: .normal)
        }
        numOfPost.text = "\((user["posts"] as! [String]).count)"
        numOfFollowers.text = "\((user["followers"] as! [String]).count)"
        numOfFollowing.text = "\((user["following"] as! [String]).count)"
    }
    @IBAction func btnFollowClick(_ sender: UIButton) {
        print()
        if btnFollow.titleLabel?.text == FOLLOW {
            UserDB.shared.exeFollowing(follower: follower, following: following)
            numOfFollowers.text = "\((user["followers"] as! [String]).count+1)"
            btnFollow.setTitle(UNFOLLOW, for: .normal)
        }
        else {
            numOfFollowers.text = "\((user["followers"] as! [String]).count-1)"
            UserDB.shared.exeUnFollowing(follower: follower, following: following)
            btnFollow.setTitle(FOLLOW, for: .normal)
        }
    }
}
