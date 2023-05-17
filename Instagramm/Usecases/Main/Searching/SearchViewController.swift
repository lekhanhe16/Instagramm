//
//  SearchProfileViewController.swift
//  Instagramm
//
//  Created by acupofstarbugs on 06/05/2023.
//

import UIKit
import RxSwift

class SearchViewController: UIViewController {
    @IBOutlet var searchBarProfile: UISearchBar!
    var searchResult: SearchResultViewController!
    var suggestionsView: SearchSuggestionsView!
    
    var disposeBag = DisposeBag()
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupSearchBar()
        searchResult = UIStoryboard(name: "SearchResult", bundle: nil).instantiateViewController(withIdentifier: "searchresultvc") as! SearchResultViewController
        
        addChild(searchResult)
        searchResult.view.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
        view.addSubview(searchResult.view)
        searchResult.view.isHidden = true
        searchResult.didMove(toParent: self)
    }
    
    func setupSearchBar() {
        navigationItem.titleView = searchBarProfile
        searchBarProfile.delegate = self
        if searchBarProfile.inputAccessoryView == nil {
            suggestionsView = Bundle.main.loadNibNamed("SearchSuggestionsView", owner: nil)?.first as? SearchSuggestionsView
            suggestionsView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height - 400 - (navigationController?.navigationBar.frame.height)!)
            suggestionsView.clickEvent.asObservable().subscribe(onNext: { [weak self] user in
                print(user)
                let userProfileVC = UIStoryboard(name: "UserProfile", bundle: nil).instantiateViewController(identifier: "userprofilevc") { coder in
                    UserProfileViewController(coder: coder, user: user)
                }
                userProfileVC.modalPresentationStyle = .fullScreen
                self?.navigationController?.pushViewController(userProfileVC, animated: true)
            }, onError: { err in
                print(err.localizedDescription)
            }, onCompleted: {
                print("xcomplete")
            }
            ).disposed(by: disposeBag)
            suggestionsView.setupTableView()
            searchBarProfile.inputAccessoryView = suggestionsView
            
            
        }
    }
}

extension SearchViewController: UISearchBarDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBarProfile.showsCancelButton = true
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
//        if searchBar.text?.isEmpty == true {
//            searchResult.view.isHidden = true
//            searchBarProfile.showsCancelButton = false
//            searchBarProfile.resignFirstResponder()
//        }
         if !(searchBar.text?.contains("#"))! {
            suggestionsView.getResults(kw: searchBar.text ?? "")
        }
        else {
            suggestionsView.getResultWithHashtag(hashTag: searchBar.text!)
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchResult.view.isHidden = true
        searchBarProfile.showsCancelButton = false
        searchBarProfile.resignFirstResponder()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBarProfile.showsCancelButton = false
        searchBarProfile.resignFirstResponder()
        searchResult.view.isHidden = false
    }
}
