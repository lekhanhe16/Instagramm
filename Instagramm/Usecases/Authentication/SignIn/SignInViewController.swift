//
//  SignInViewController.swift
//  Instagramm
//
//  Created by acupofstarbugs on 04/05/2023.
//

import UIKit
import FirebaseAuth

class SignInViewController: UIViewController {

    
    @IBOutlet weak var signUpLbl: UILabel!
    @IBOutlet weak var txtPwd: UITextField!
    @IBOutlet weak var txtUser: UITextField!
    
    @IBAction func btnLoginClicked(_ sender: UIButton) {
        switch validateUserInfo(user: txtUser.text, pwd: txtPwd.text) {
            case .VALID:
                Auth.auth().signIn(withEmail: txtUser.text!, password: txtPwd.text!) { [weak self] authResult, error in
                    if let err = error {
                        self?.showAlert(title: "Login failed", msg: err.localizedDescription)
                    }
                    else {
                        if let authResult = authResult {
                            print(authResult)
                            UserDB.shared.getCurrentUser(uid: authResult.user.uid)
                            let home = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MainVC")
                            self?.navigationController?.navigationItem.hidesBackButton = true
                            self?.navigationController?.pushViewController(home, animated: true)
                            self?.navigationController?.viewControllers.removeAll(where: { $0 === self?.`self`()})
                        }
                        else {
                            print("Invalid username or pwd")
                        }
                    }
                }
            case .INVALID_USER:
                showAlert(title: "Login failed", msg: "You should enter correct email address.")
            case .INVALID_PWD:
                showAlert(title: "Login failed", msg: "Your password should have 6 or more characters.")
            default:
                showAlert(title: "Login failed", msg: "You should enter correct email address. Your password should have 6 or more characters.")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        txtPwd.delegate = self
        registSignUpLblClickListener()
    }

    func registSignUpLblClickListener() {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(signUpLabelTap))
        signUpLbl.isUserInteractionEnabled = true
        signUpLbl.addGestureRecognizer(gesture)
    }
    
    @objc func signUpLabelTap() {
        navigationController?.pushViewController(UIStoryboard(name: "Login", bundle: nil).instantiateViewController(withIdentifier: "SignUpVC"), animated: true)
    }
    deinit {
        print("SignInViewController deinit")
    }
    
}

extension SignInViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        txtPwd.resignFirstResponder()
        return false
    }
}
