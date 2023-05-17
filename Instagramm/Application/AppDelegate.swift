//
//  AppDelegate.swift
//  Instagramm
//
//  Created by acupofstarbugs on 04/05/2023.
//

import FirebaseAuth
import FirebaseCore
import FirebaseFirestore
import UIKit.UIWindow

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        FirebaseApp.configure()
        window = UIWindow()
        var initialController: UIViewController
        
        if Auth.auth().currentUser != nil {
            do {
//                try Auth.auth().signOut()
            }
            catch {
                print(error)
            }
            initialController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MainVC")
            
        }
        else {
            initialController = UINavigationController(rootViewController: UIStoryboard(name: "Login", bundle: nil).instantiateViewController(withIdentifier: "SignInVC"))
        }
        window?.rootViewController = initialController
        window?.makeKeyAndVisible()
        return true
    }
}
