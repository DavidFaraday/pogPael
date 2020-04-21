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
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    //MARK: - Vars

    var statusLabelStrings = ["Connecting to cloud...", "Checking for user content", "Fetching user data..", "Applying changes...", "Finishing..."]
    
    var shouldContinue = true
    
    //MARK: - ViewLifeCycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.updateStatusLabel(labelNumber: 0)

        createNewButtonOutlet.layer.cornerRadius = 8
        activityIndicator.startAnimating()
        
        startCheckingForAccounts()

    }
    
    private func updateStatusLabel(labelNumber: Int) {
        statusLabel.text = statusLabelStrings[labelNumber]
    }
    
    @IBAction func createNewButtonPressed(_ sender: Any) {
        
        checkForAccount()
    }
    
    
    private func startCheckingForAccounts() {
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            
            self.updateStatusLabel(labelNumber: 1)
            print("......5......")
            self.checkForAccount()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
            if self.shouldContinue {
                
                self.updateStatusLabel(labelNumber: 2)
                print("......10......")
                self.checkForAccount()
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 15) {
            
            if self.shouldContinue {
                self.updateStatusLabel(labelNumber: 3)
                
                print("......15......")
                self.checkForAccount()
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 20) {
            
            if self.shouldContinue {
                self.updateStatusLabel(labelNumber: 4)
                
                print("......20......")
                self.shouldContinue = false
                self.checkForAccount()
            }
        }
        
    }
    
    private func checkForAccount() {

        let allAccounts = fetchAccounts()
        
        if allAccounts.count > 0 {
            
            for account in allAccounts {
                
                if account.id?.uuidString == "C33A112A-4A36-4385-ABE8-25830DA17CE4" {
                    print("found one")
                    self.shouldContinue = false

                    goToApp()
                    return
                }
            }
            
        }
    
        
        if !shouldContinue {
            print("fed up")
            UserAccount.createAccount(name: "Main Account", image: nil, iD: UUID(uuidString: "C33A112A-4A36-4385-ABE8-25830DA17CE4") ?? UUID())
            
            goToApp()
        }
    }
    
    
    private func fetchAccounts() -> [Account] {

        var allAccounts: [Account] = []
        let context = AppDelegate.context

        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Account")
        fetchRequest.sortDescriptors = []


        do {
            allAccounts = try context.fetch(fetchRequest) as! [Account]

        } catch {
            print("Failed to fetch account")
        }

        return allAccounts
    }

    
    private func goToApp() {
        let mainAppVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "mainAPP") as! UITabBarController
        
        mainAppVC.modalPresentationStyle = .fullScreen
        
        self.present(mainAppVC, animated: true, completion: nil)

    }
}
