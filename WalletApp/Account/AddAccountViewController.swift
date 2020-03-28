//
//  AddAccountViewController.swift
//  WalletApp
//
//  Created by David Kababyan on 28/03/2020.
//  Copyright © 2020 David Kababyan. All rights reserved.
//

import UIKit

protocol AddAccountViewControllerDelegate {
    func didCreateAccount()
}

class AddAccountViewController: UIViewController {

    //MARK: - IBOutlets
    @IBOutlet weak var accountNameLabel: UILabel!
    @IBOutlet weak var doneButtonOutlet: UIButton!
    @IBOutlet weak var accountNameTextField: UITextField!
    @IBOutlet weak var avatarImageView: UIImageView!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var topBackground: UIView!

    //MARK: - Vars
    var avatarImage: UIImage?
    var accountToEdit: Account?
    
    var delegate: AddAccountViewControllerDelegate?
    
    //MARK: - ViewLife Cycle
    
    override func viewWillAppear(_ animated: Bool) {
        super .viewWillAppear(true)
        
        if accountToEdit != nil {
            setAccountInfo()
        }
        
        updateDoneButtonStatus()
        setupUI()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        addTextFieldDidChangeListeners()
        addImageViewTap()
    }
    
    
    //MARK: - IBActions
    @IBAction func cancelButtonPressed(_ sender: Any) {
        dismissKeyboard()
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func doneButtonPressed(_ sender: Any) {
         
        if isDataInputed() {
            
            if accountToEdit == nil {
                UserAccount.changeAccountStatus()
                UserAccount.createAccount(name: accountNameTextField.text!, image: avatarImage)
                
            } else {
                accountToEdit!.name = accountNameTextField.text
                accountToEdit!.image = avatarImage != nil ? UIImageJPEGRepresentation(avatarImage!, 1.0) : nil
            }
            
            delegate?.didCreateAccount()
            self.dismiss(animated: true, completion: nil)
        }
        
    }
    
    @IBAction func backgroundTap(_ sender: Any) {
        
        dismissKeyboard()
    }
    
    @objc func textFieldDidChange(textField: UITextField) {
        
        accountNameLabel.text = accountNameTextField.text
        updateDoneButtonStatus()
    }
    
    
    @objc func avatarTap() {
        //TODO: Add image picker

        print("tap")
        
    }
    
    
    //MARK: - Helpers
    private func dismissKeyboard() {
        self.view.endEditing(false)
    }

    private func isDataInputed() -> Bool {
        return accountNameTextField.text != ""
    }
    
    
    //MARK: - UpdateUI

    private func updateDoneButtonStatus() {
        
        doneButtonOutlet.isEnabled = isDataInputed()
        
    }
    
    //MARK: - SetupUI
    
    private func setAccountInfo() {
        
        titleLabel.text = "Edit Account"
        
        accountNameLabel.text = accountToEdit!.name
        accountNameTextField.text = accountToEdit!.name
        
        if accountToEdit!.image != nil {
            avatarImageView.image = UIImage(data: accountToEdit!.image!)
        }
        
    }
    
    private func setupUI() {
        
        backgroundView.layer.cornerRadius = 10
        
        self.topBackground.applyGradient(colors: [
            UIColor(named: "gradientStartColor")!.cgColor,
            UIColor(named: "gradientEndColor")!.cgColor],
                                         locations: [0.0, 1.0],
                                         direction: .leftToRight, cornerRadius: 10)
                
        topBackground.layer.cornerRadius = 10
        topBackground.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
    }
    
    private func addTextFieldDidChangeListeners() {
        
        accountNameTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
    }

    private func addImageViewTap() {
        avatarImageView.isUserInteractionEnabled = true
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(avatarTap))
        avatarImageView.addGestureRecognizer(tapGesture)
        
    }

}
