//
//  LoginViewController.swift
//  FutureLove
//
//  Created by TTH on 24/07/2023.
//

import UIKit
import Toast_Swift
import SwiftKeychainWrapper


class LoginViewController: BaseViewController {
    
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var passWordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var showPasswordButton: UIButton!
    @IBOutlet weak var registerLabel: UILabel!
    @IBOutlet weak var errorMessageLabel: UILabel!
    @IBOutlet weak var imageBackground: UIImageView!
    @IBOutlet weak var oldLoginLabel: UILabel!
    
    @IBAction func backApp(){
        self.dismiss(animated: true)
    }
    
    func setDataPro(){
        if let number_user: Int = KeychainWrapper.standard.integer(forKey: "saved_login_account"){
            for item in 0..<number_user{
                let emailUserKey = "email_login_" + String(item + 1)
                if let emailUser: String = KeychainWrapper.standard.string(forKey: emailUserKey){
                    self.userNameTextField.text = emailUser
                }
                let idPassUser = "pass_login_" + String(item + 1)
                if let passEmail: String = KeychainWrapper.standard.string(forKey: idPassUser){
                    self.passWordTextField.text = passEmail
                }
            }
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let emailUser: String = KeychainWrapper.standard.string(forKey: "email_login_temp"){
            if emailUser != ""{
                self.userNameTextField.text = emailUser
                KeychainWrapper.standard.set("", forKey: "email_login_temp")
                if let passEmail: String = KeychainWrapper.standard.string(forKey: "pass_login_temp"){
                    self.passWordTextField.text = passEmail
                    KeychainWrapper.standard.set("", forKey: "pass_login_temp")
                }
                KeychainWrapper.standard.set("", forKey: "time_login_temp")
            }else{
                setDataPro()
            }
            
        }else{
            setDataPro()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
        hideKeyboardWhenTappedAround()
        callApiIP()
        self.errorMessageLabel.text = ""
        showPasswordButton.setTitle("", for: .normal)
        backButton.setTitle("", for: .normal)
    }
    
    func callApiIP(){
        RegisterAPI.shared.getIP { result in
            switch result {
            case .success(let success):
                AppConstant.saveIp(model: success)
            case .failure(let failure):
                print(failure)
            }
        }
    }
    
    @IBAction func btnLogin(_ sender: Any) {
        guard userNameTextField.text != "" && passWordTextField.text != "" else {
            if userNameTextField.text == "" {
                self.view.makeToast("UserName or Email cannot be blank", position: .top)
            } else {
                self.view.makeToast("Password cannot be left blank",position: .top)
            }
            return
        }
        showCustomeIndicator()
        let parameters = ["email_or_username": userNameTextField.text.asStringOrEmpty(), "password": passWordTextField.text.asStringOrEmpty()]
        APIService.shared.LoginAPI(param: parameters){result, error in
            self.hideCustomeIndicator()
            if result?.id_user == nil  {
                self.view.makeToast(result?.ketqua, position: .top)
                self.errorMessageLabel.text = result?.ketqua
                if let messagePro = result?.ketqua{
                    self.showAlert(message: messagePro)
                    return
                }
                //                self.showAlert(message: (result?.ketqua) ?? "Password Wrong Or Account Not Register Or Account Not Verify Email")
                //                return
            }
            if let result = result{
                AppConstant.saveUser(model: result)
                if let number_user: Int = KeychainWrapper.standard.integer(forKey: "saved_login_account"){
                    let number_userPro = number_user + 1
                    KeychainWrapper.standard.set(number_userPro, forKey: "saved_login_account")
                    if let resultEmail = (result.email){
                        let idUserNumber = "email_login_" + String(number_userPro)
                        KeychainWrapper.standard.set(resultEmail, forKey: idUserNumber)
                        let idPassUser = "pass_login_" + String(number_userPro)
                        KeychainWrapper.standard.set(self.passWordTextField.text.asStringOrEmpty(), forKey: idPassUser)
                        let idTimeUser = "time_login_" + String(number_userPro)
                        let timeNow = DateFormatter.localizedString(from: NSDate() as Date, dateStyle: .medium, timeStyle: .short)
                        KeychainWrapper.standard.set(timeNow, forKey: idTimeUser)
                    }
                }else{
                    KeychainWrapper.standard.set(1, forKey: "saved_login_account")
                    if let resultEmail = (result.email){
                        let idUserNumber = "email_login_" + String(1)
                        KeychainWrapper.standard.set(resultEmail, forKey: idUserNumber)
                        let idPassUser = "pass_login_" + String(1)
                        KeychainWrapper.standard.set(self.passWordTextField.text.asStringOrEmpty(), forKey: idPassUser)
                        let timeNow = DateFormatter.localizedString(from: NSDate() as Date, dateStyle: .medium, timeStyle: .short)
                        let idTimeUser = "time_login_" + String(1)
                        KeychainWrapper.standard.set( timeNow, forKey: idTimeUser)
                    }
                }
            }
            let storyboard = UIStoryboard(name: "Main", bundle: nil) // type storyboard name instead of Main
            if let myViewController = storyboard.instantiateViewController(withIdentifier:"CategoriesWeddingVC") as? CategoriesWeddingVC {
                myViewController.modalPresentationStyle = .fullScreen
                self.present(myViewController, animated: true, completion: nil)
                
            }
            
        }
    }
    
    @IBAction func actionBtnHiden(_ sender: Any) {
        if passWordTextField.isSecureTextEntry == true {
            passWordTextField.isSecureTextEntry = false
        } else {
            passWordTextField.isSecureTextEntry = true
        }
    }
    
    @IBAction func btnResetPass(_ sender: Any) {
        if let nextViewController = self.storyboard?.instantiateViewController(withIdentifier: "FogotPassViewController") as? FogotPassViewController {
            // Present view controller
            nextViewController.modalPresentationStyle = .fullScreen
            self.present(nextViewController, animated: true, completion: nil)
            print("Done")
        }
    }

    @objc func tapLabelProvision(tap: UITapGestureRecognizer) {
        let vc = RegisterViewController(nibName: "RegisterViewController", bundle: nil)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func SkipLoginAccount(){
        AppConstant.userId = nil
        self.navigationController?.setRootViewController(viewController: TabbarViewController(),
                                                         controllerType: TabbarViewController.self)
    }
    
    @IBAction func loadNext(){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "RegisterViewController") as! RegisterViewController
        vc.modalPresentationStyle = .fullScreen //or .overFullScreen for transparency
        self.present(vc, animated: true, completion: nil)
    }
}
