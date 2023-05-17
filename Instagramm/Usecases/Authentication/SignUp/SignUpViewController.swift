//
//  SignUpViewController.swift
//  Instagramm
//
//  Created by acupofstarbugs on 05/05/2023.
//

import UIKit
import FirebaseAuth

class SignUpViewController: UIViewController {

    @IBOutlet weak var txtConfirmPwd: UITextField!
    @IBOutlet weak var txtPwd: UITextField!
    @IBOutlet weak var txtUsername: UITextField!
    @IBOutlet weak var txtEmail: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = false
    }

    @IBAction func btnSignUpClick(_ sender: UIButton) {
        switch validateSignUpUserInfo(user: txtEmail.text, pwd: txtPwd.text, confirmPwd: txtConfirmPwd.text) {
            case .VALID:
                guard let userName = txtUsername.text else {
                    return
                }
                UserDB.shared.isUsernameValid(username: userName) { [weak self] isValid in
                    if isValid {
                        Auth.auth().createUser(withEmail: (self?.txtEmail.text)!, password: (self?.txtPwd.text)!) { result, error in
                            if let err = error {
                                self?.showAlert(title: "Signup failed", msg: err.localizedDescription)
                            }
                            else {
                                UserDB.shared.signUpNewUser(username: userName, uid: (result?.user.uid)!)
                                let home = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MainVC")
                                self?.navigationController?.navigationItem.hidesBackButton = true
                                self?.navigationController?.pushViewController(home, animated: true)
                                self?.navigationController?.viewControllers.removeAll(where: { $0 !== home})
                            }
                        }
                    }
                    else {
                        self?.showAlert(title: "Signup failed", msg: "Your username is already in use by another account.")
                        print("not unique username")
                    }
                }
//                if userName.isEmpty
            case .INVALID_USER:
                showAlert(title: "Signup failed", msg: "You should enter correct email address.")
                print("invalid email address")
            case .INVALID_PWD:
                showAlert(title: "Signup failed", msg: "Your password should have 6 or more characters.")
                print("invalid password")
            case .INVALID_BOTH:
                showAlert(title: "Signup failed", msg: "You should enter correct email address. Your password should have 6 or more characters.")
                print("invalid email pwd")
            case .PWD_NOT_ALIKE:
                showAlert(title: "Signup failed", msg: "You should confirm your password correctly.")
                print("pwd not alike")
        }
    }
    deinit{
        print("signup vc deinit")
    }
}
