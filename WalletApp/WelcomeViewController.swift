//
//  WelcomeViewController.swift
//  WalletApp
//
//  Created by David Kababyan on 13/04/2020.
//  Copyright © 2020 David Kababyan. All rights reserved.
//

import UIKit
import CloudKit
import CoreData


class WelcomeViewController: UIViewController {
    
    //MARK: - IBOutlets
    
    @IBOutlet weak var createNewButtonOutlet: UIButton!
    @IBOutlet weak var restoreButtonOutlet: UIButton!
    
    //MARK: - ViewLifeCycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        createNewButtonOutlet.layer.cornerRadius = 8
        restoreButtonOutlet.layer.cornerRadius = 8

    }

    @IBAction func createNewButtonPressed(_ sender: Any) {
        
        UserAccount.createAccount(name: "Main Account", image: nil)
        
        let loginVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "mainAPP") as! UITabBarController
        
        loginVC.modalPresentationStyle = .fullScreen
        
        self.present(loginVC, animated: true, completion: nil)
    }
    
    
    @IBAction func restoreButtonPressed(_ sender: Any) {
        
        let loginVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "loginView") as! LoginViewController
        
        loginVC.firstRun = true
        
        self.present(loginVC, animated: true, completion: nil)
    }
    
}
