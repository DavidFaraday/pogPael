//
//  LoginViewController.swift
//  WalletApp
//
//  Created by David Kababyan on 17/04/2020.
//  Copyright © 2020 David Kababyan. All rights reserved.
//

import UIKit

protocol LoginViewControllerDelegate {
    func didDismiss()
}

class LoginViewController: UIViewController {

    
    //MARK: - IBOutlets
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var repeatPasswordTextField: UITextField!
    
    @IBOutlet weak var loginButtonOutlet: UIButton!
    @IBOutlet weak var forgotPasswordButtonOutlet: UIButton!
    @IBOutlet weak var resendEmailButtonOutlet: UIButton!
    @IBOutlet weak var signUpButtonOutlet: UIButton!
    
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
    //MARK: - Vars
    var showingRegister = false
    var notificationController: NotificationController!

    var delegate: LoginViewControllerDelegate?
    var firstRun = false
    
    //MARK: - View Lifecycle
    override func viewWillDisappear(_ animated: Bool) {
        delegate?.didDismiss()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadingIndicator.isHidden = true
        notificationController = NotificationController(_view: self.view)
        roundButtonCorners()
    }
    
    //MARK: - IBActions
    @IBAction func loginButtonPressed(_ sender: Any) {
        
        if showingRegister {

            if isDataInputed(Constants.registration) {
                
                if isPasswordMatch() {
                    registerUser()
                } else {
                    self.notificationController.showNotification(text: "Passwords don't match!", isError: true)

                }
                
            } else {
                self.notificationController.showNotification(text: "All fields are required!", isError: true)
            }
        } else {

            if isDataInputed(Constants.login) {
                loginUser()
                
            } else {
                self.notificationController.showNotification(text: "All fields are required!", isError: true)
            }
        }
        
        dismissKeyboard()

    }
    
    @IBAction func forgotPasswordButtonPressed(_ sender: Any) {
        
        if isDataInputed(Constants.forgotPassword) {

            FUser.resetPasswordFor(email: emailTextField.text!) { (error) in
                
                if error == nil {
                    self.notificationController.showNotification(text: "Password reset email sent!", isError: false)
                } else {
                    self.notificationController.showNotification(text: error!.localizedDescription, isError: true)
                }
            }

        } else {
            self.notificationController.showNotification(text: "Please input email!", isError: true)
        }

    }
    
    @IBAction func resendEmailButtonPressed(_ sender: Any) {
        
        if isDataInputed(Constants.resendEmail) {
            
            showLoadingIndicator()

            FUser.resendVerificationEmail(email: emailTextField.text!) { (error) in
                
                self.hideLoadingIndicator()

                if error == nil {
                    self.notificationController.showNotification(text: "Verification email sent!", isError: false)

                } else {
                    self.notificationController.showNotification(text: error!.localizedDescription, isError: true)
                }
                
            }
        } else {
            self.notificationController.showNotification(text: "Please input email!", isError: true)
        }

    }
    
    @IBAction func signupButtonPressed(_ sender: Any) {
        dismissKeyboard()
        
        showingRegister = !showingRegister
        animateRegister(showingRegister)
        
        self.changeForgotPasswordButtonStatus(true)
        self.changeResendEmailButtonStatus(true)
    }
    
    @IBAction func backgroundTap(_ sender: Any) {
        dismissKeyboard()
    }
    
    //MARK: - Register functions
    
    private func registerUser() {
        
        showLoadingIndicator()

        FUser.registerUserWith(email: emailTextField.text!, password: passwordTextField.text!) { (error) in
            
            if error == nil {

                self.notificationController.showNotification(text: "Verification email sent!", isError: false)

                self.resetToLogin()
                self.changeResendEmailButtonStatus(false)
            } else {
                self.notificationController.showNotification(text: error!.localizedDescription, isError: true)
            }
            
            self.hideLoadingIndicator()

        }
    }
    
    private func loginUser() {
        
        showLoadingIndicator()

        FUser.loginUserWith(email: emailTextField.text!, password: passwordTextField.text!) { (error, isEmailVerified) in

            if error == nil {
                
                if isEmailVerified {
                    
                    if self.firstRun {
                        
                        self.loadAccountsFromCloud()
                        self.loadExpensesFromCloud()
                        
                        enableCloudSync()
                        
                        self.goToApp()
                        
                    } else {
                        self.dismiss(animated: true, completion: nil)
                    }
                    
                } else {
                    self.notificationController.showNotification(text:
                    "Please verify your email!", isError: true)
                    self.changeResendEmailButtonStatus(false)
                }
                
            } else {
                self.notificationController.showNotification(text:
                error!.localizedDescription, isError: true)

                self.changeForgotPasswordButtonStatus(false)
            }
            
            self.hideLoadingIndicator()

        }

        dismissKeyboard()
    }
    
    //MARK: - Setup UI
    
    private func roundButtonCorners() {
        
        loginButtonOutlet.layer.cornerRadius = 8
        resendEmailButtonOutlet.layer.cornerRadius = 8
        resendEmailButtonOutlet.layer.cornerRadius = 8
        
        emailTextField.overrideUserInterfaceStyle = .light
        passwordTextField.overrideUserInterfaceStyle = .light
        repeatPasswordTextField.overrideUserInterfaceStyle = .light
    }
    
    //MARK: - UPdate UI
    private func showLoadingIndicator() {
        
        loadingIndicator.isHidden = false
        loadingIndicator.startAnimating()
    }
    
    private func hideLoadingIndicator() {
        
        loadingIndicator.isHidden = true
        loadingIndicator.stopAnimating()
    }

    //MARK: - Helper functions
    private func dismissKeyboard() {
        self.view.endEditing(false)
    }


    private func isDataInputed(_ forAction: Int) -> Bool {
        
        switch forAction {
        case Constants.login:
            return emailTextField.text != "" && passwordTextField.text != ""
        case Constants.registration:
            return emailTextField.text != "" && passwordTextField.text != "" && repeatPasswordTextField.text != ""
        case Constants.resendEmail:
            return emailTextField.text != ""
        case Constants.forgotPassword:
            return emailTextField.text != ""
        default:
            return false
        }

    }

    private func isPasswordMatch() -> Bool {
        return passwordTextField.text! == repeatPasswordTextField.text!
    }

    private func resetToLogin() {
        
        showingRegister = false
        dismissKeyboard()
        animateRegister(false)
        cleanTextFields()
    }
    
    private func cleanTextFields() {
        passwordTextField.text = ""
        repeatPasswordTextField.text = ""
    }
    
    
    private func loadAccountsFromCloud() {
        
        FirebaseAccount.loadAccounts { (allAccounts) in
            
            CoreDataManager.sharedManager.saveFirebaseAccountsToCD(firebaseAccounts: allAccounts)
        }
    }
    
    private func loadExpensesFromCloud() {
        
        FirebaseExpense.loadExpenses(completion: { (allExpenses) in
            
            CoreDataManager.sharedManager.saveFirebaseExpensesToCD(firebaseExpenses: allExpenses)
        })
    }

    
    private func goToApp() {
        
        let loginVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "mainAPP") as! UITabBarController
        
        loginVC.modalPresentationStyle = .fullScreen
        
        self.present(loginVC, animated: true, completion: nil)
    }
    
    //MARK: - Reset Password

    private func resetPassword() {
        
        showLoadingIndicator()

        FUser.resetPasswordFor(email: emailTextField.text!) { (error) in
            
            self.hideLoadingIndicator()

            if error == nil {
                
                self.notificationController.showNotification(text: "Reset password link sent!", isError: false)
            } else {
                self.notificationController.showNotification(text: error!.localizedDescription, isError: true)
            }
        }
    }

    
    //MARK: - Animations
    private func animateRegister(_ showRegister: Bool) {
        
        var signUpButtonTitle = "Dont have an account? Sign Up"
        var loginButtonTitle = "Login"

        
        UIView.animate(withDuration: 0.5) {
            
            if showRegister {
                
                signUpButtonTitle = "I have account, Login"
                loginButtonTitle = "Register"
                self.repeatPasswordTextField.isHidden = false
            } else {
                
                signUpButtonTitle = "Don't have an account? Sign Up"
                loginButtonTitle = "Login"
                self.repeatPasswordTextField.isHidden = true
            }

            self.signUpButtonOutlet.setTitle(signUpButtonTitle, for: .normal)
            self.loginButtonOutlet.setTitle(loginButtonTitle, for: .normal)
        }
    }

    
    func changeResendEmailButtonStatus(_ isHidden: Bool) {
        
        UIView.animate(withDuration: 0.5) {
            
            self.resendEmailButtonOutlet.isHidden = isHidden
        }
    }
    
    private func changeForgotPasswordButtonStatus(_ isHidden: Bool) {
         
         UIView.animate(withDuration: 0.5) {
             
             self.forgotPasswordButtonOutlet.isHidden = isHidden
         }
     }


}
