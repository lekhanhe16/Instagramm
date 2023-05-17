//
//  UserValidationUtils.swift
//  Instagramm
//
//  Created by acupofstarbugs on 04/05/2023.
//

import Foundation

enum TextFieldValidation {
    case VALID, INVALID_USER, INVALID_PWD, INVALID_BOTH, PWD_NOT_ALIKE
}

private let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}"

func isValidUsername(username: String?) -> Bool {
    if username == nil {
        return false
    }
    else {
        if let username = username, username.isEmpty || !NSCompoundPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: username) {
            return false
        }
    }
    return true
}

func isValidPwd(pwd: String?) -> Bool {
    guard let pwd = pwd else { return false }
    if pwd.count < 6 {
        return false
    }
    return true
}

func validateUserInfo(user: String?, pwd: String?) -> TextFieldValidation{
    let validUsername = isValidUsername(username: user)
    let validPwd = isValidPwd(pwd: pwd)
    
    if !validPwd && !validUsername {
        return TextFieldValidation.INVALID_BOTH
    }
    else if !validUsername {
        return TextFieldValidation.INVALID_USER
    }
    else if !validPwd {
        return TextFieldValidation.INVALID_PWD
    }
    return TextFieldValidation.VALID
}

func validateSignUpUserInfo(user: String?, pwd: String?, confirmPwd: String?) -> TextFieldValidation {
    let validUsername = isValidUsername(username: user)
    let validPwd = isValidPwd(pwd: pwd)
    let cfPwd = confirmPwd ?? ""
    if !validPwd && !validUsername {
        return TextFieldValidation.INVALID_BOTH
    }
    else if !validUsername {
        return TextFieldValidation.INVALID_USER
    }
    else if !validPwd {
        return TextFieldValidation.INVALID_PWD
    }
    else if validPwd && validUsername && pwd! != cfPwd {
        return TextFieldValidation.PWD_NOT_ALIKE
    }
    return TextFieldValidation.VALID
}
