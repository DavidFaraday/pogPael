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
    
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    //MARK: - Vars

    var statusLabelStrings = ["Connecting to cloud...", "Checking for user content", "Fetching user data..", "Applying changes...", "Finishing..."]
    
    var shouldContinue = true
    
    //MARK: - ViewLifeCycle

    override func viewDidLoad() {
        super.viewDidLoad()

        activityIndicator.startAnimating()
        
        startCheckingForAccounts()

    }
    
    private func updateStatusLabel(labelNumber: Int) {
        statusLabel.text = statusLabelStrings[labelNumber]
    }
    
    
    
    private func startCheckingForAccounts() {
        
        self.updateStatusLabel(labelNumber: 0)
        self.checkForAccount()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            if self.shouldContinue {
                
                self.updateStatusLabel(labelNumber: 1)
                print("......5......")
                self.checkForAccount()
            }
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
            
            var accountIndex = 1
            
            for account in allAccounts {
                
                print("...", account.name, account.id?.uuidString)
                
                if allAccounts.count == 1 {
                    //we have only 1 account check if its the main
                    fetchAndUpdateExpenses(oldUserId: account.id!.uuidString)
                    updateAccountToDefaultId(account: account)

                } else {
                    //find main account and update ID
                    
                    if account.name == "Main Account" {
                        print("found main account. updating")

                        fetchAndUpdateExpenses(oldUserId: account.id!.uuidString)
                        updateAccountToDefaultId(account: account)
                    } else {
                        
                        if accountIndex == allAccounts.count {
                            print("THIS IS LAST ACCOUNT")
                            fetchAndUpdateExpenses(oldUserId: account.id!.uuidString)
                            updateAccountToDefaultId(account: account)
                        }
                        accountIndex += 1
                        print("didnt find main account. what to do?")
                    }
                    
                }
                
                //we have a default account, go to app
                if account.id?.uuidString == kDEFAULTUSERID {
                    print("found default account, going to app")
                    self.shouldContinue = false
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        //adding a bit delay to make transition work
                        self.goToApp()
                    }
                    return
                }
            }
            
        }
    
        //didnt find accounts, make new one
        if !shouldContinue {

            UserAccount.createAccount(name: "Main Account", image: nil, iD: UUID(uuidString: kDEFAULTUSERID) ?? UUID())
            
            goToApp()
        }
    }
    
    private func updateAccountToDefaultId(account: Account) {
        UserAccount.changeAccountStatus()
        account.id = UUID(uuidString: kDEFAULTUSERID)
        account.isCurrent = true
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
    }
    
    private func fetchAndUpdateExpenses(oldUserId: String){

        let context = AppDelegate.context
        var allExpenses: [Expense] = []
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Expense")
        fetchRequest.sortDescriptors = []
        fetchRequest.predicate = NSPredicate(format: "userId = %@", oldUserId)

        do {
            allExpenses = try context.fetch(fetchRequest) as! [Expense]

        } catch {
            print("Failed to fetch account")
        }

        
        updateExpenseIdsToNew(expenses: allExpenses)
    }
    
    private func updateExpenseIdsToNew(expenses: [Expense]) {
        
        for expense in expenses {
            expense.userId = UUID(uuidString: kDEFAULTUSERID)
        }
        
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
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
