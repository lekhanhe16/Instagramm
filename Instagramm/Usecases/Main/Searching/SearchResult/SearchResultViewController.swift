//
//  SearchResultViewController.swift
//  Instagramm
//
//  Created by acupofstarbugs on 06/05/2023.
//

import UIKit
import LZViewPager

class SearchResultViewController: UIViewController {

    private var fragments: [UIViewController] = []
    private var currentIndex = 0
    @IBOutlet weak var viewPager: LZViewPager!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setUpViewPager()
    }
    
    func setUpViewPager() {
        let forYou = UIStoryboard(name: "ForYou", bundle: nil).instantiateViewController(withIdentifier: "foryouvc")
        let account = UIStoryboard(name: "Accounts", bundle: nil).instantiateViewController(withIdentifier: "accountvc")
        let account1 = UIStoryboard(name: "Accounts", bundle: nil).instantiateViewController(withIdentifier: "accountvc")
        let account2 = UIStoryboard(name: "Accounts", bundle: nil).instantiateViewController(withIdentifier: "accountvc")
        let account3 = UIStoryboard(name: "Accounts", bundle: nil).instantiateViewController(withIdentifier: "accountvc")
        let account4 = UIStoryboard(name: "Accounts", bundle: nil).instantiateViewController(withIdentifier: "accountvc")
        let account5 = UIStoryboard(name: "Accounts", bundle: nil).instantiateViewController(withIdentifier: "accountvc")
        let account6 = UIStoryboard(name: "Accounts", bundle: nil).instantiateViewController(withIdentifier: "accountvc")
        
        forYou.title = "For you"
        account.title = "Accounts"
        account1.title = "Reels"
        account2.title = "Accounts2"
        account3.title = "Accounts3"
        account4.title = "Accounts4"
        account5.title = "Accounts5"
        account6.title = "Accounts6"
        
        viewPager.delegate = self
        viewPager.dataSource = self
        viewPager.hostController = self
        fragments = [forYou, account, account1, account2, account3, account4, account5, account6]
        viewPager.reload()
    }
    
}

extension SearchResultViewController: LZViewPagerDataSource{
    func numberOfItems() -> Int {
        return fragments.count
    }
    
    func controller(at index: Int) -> UIViewController {
        return fragments[index]
    }
    
    func button(at index: Int) -> UIButton {
        let button = UIButton()
        button.setTitleColor(UIColor.black, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        button.frame.size.width = 100
        return button
    }
    
    func colorForIndicator(at index: Int) -> UIColor {
        return .black
    }
    
    func widthForButton(at index: Int) -> CGFloat {
        return 100
    }
}

extension SearchResultViewController: LZViewPagerDelegate {
    func didSelectButton(at index: Int) {
        currentIndex = index
    }
    func willTransition(to index: Int) {
        
    }
    func didTransition(to index: Int) {
    }
}
