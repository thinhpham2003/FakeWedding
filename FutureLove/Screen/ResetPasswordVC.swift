//
//  ResetPasswordVC.swift
//  FutureLove
//
//  Created by Phạm Quý Thịnh on 29/02/2024.
//

import UIKit

class ResetPasswordVC: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
        hideKeyboardWhenTappedAround()

    }


    @IBAction func backBtn(_ sender: Any) {
        self.navigationController?.popViewController(animated: false)
    }

    @IBAction func resetPasswordBtn(_ sender: Any) {
        guard emailTextField.text != "" else {
            self.view.makeToast("Email cannot be blank")
            return
        }
        showCustomeIndicator()
        var paramSend:[String: String] = ["email":(emailTextField.text ?? "")]
        APIService.shared.resetPassword(param: paramSend) { response,error  in
            if let response = response{
                print(response)
                self.showAlert(message: response.message ?? "")
                self.view.makeToast(response.message)
            }
        }

    }

}
