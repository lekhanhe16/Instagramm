//
//  SearchSuggestionsView.swift
//  Instagramm
//
//  Created by acupofstarbugs on 06/05/2023.
//

import UIKit
import RxSwift

class SearchSuggestionsView: UIView {
    var users = [[String:Any]]()
    var isSearchingUser = true
    var clickEvent = PublishSubject<[String:Any]>()
    
    func setupTableView() {
        suggestionsTable.register(UINib(nibName: "SuggestionCell", bundle: nil), forCellReuseIdentifier: "suggestioncell")
        suggestionsTable.delegate = self
        suggestionsTable.dataSource = self
        
    }
    @IBOutlet weak var suggestionsTable: UITableView!
    
    func getResultWithHashtag(hashTag: String) {
        isSearchingUser = false
    }
    
    func getResults(kw: String){
        isSearchingUser = true
        UserDB.shared.searchForUsersWithName(withName: kw.lowercased()) {[weak self] suggestions, err in
            if suggestions == nil && err == nil {
                print("undefined")
            }
            else if let error = err, suggestions == nil {
                print(error.localizedDescription)
            }
            else if let suggestions = suggestions {
                self?.users = suggestions
                DispatchQueue.main.async {
                    self?.suggestionsTable.reloadData()
                }
            }
        }
    }
}

extension SearchSuggestionsView : UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let user = users[indexPath.row]
        clickEvent.onNext(user)
    }
}
extension SearchSuggestionsView : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "suggestioncell") as! SuggestionCell
        cell.cellText.text = (users[indexPath.row] as [String:Any])["username"] as? String
        return cell
    }
    
    
}
