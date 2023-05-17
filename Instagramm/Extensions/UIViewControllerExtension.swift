//
//  UIViewControllerExtension.swift
//  Instagramm
//
//  Created by acupofstarbugs on 05/05/2023.
//

import Foundation
import UIKit.UIViewController

extension UIViewController {
    func showAlert(title: String, msg: String) {
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .cancel)
        alert.addAction(action)
        self.present(alert, animated: true)
        
    }
}
