//
//  CloudManager.swift
//  WalletApp
//
//  Created by David Kababyan on 18/04/2020.
//  Copyright © 2020 David Kababyan. All rights reserved.
//

import Foundation
import UIKit

class CloudManager {
    
    static let sharedManager = CloudManager()
    
    private init() {}

    //MARK: - Account
    func saveAccountToCloud(account: Account) {
        
        let shouldSync = userDefaults.object(forKey: kSYNCTOCLOUD) as? Bool ?? false
        
        if FUser.currentUser() != nil && shouldSync {
            
            if account.image != nil {
                //uploadImage
                uploadImage(account.image!, id: account.id!.uuidString, forExpense: false) { (imageLink) in
                    
                    let fireBaseAccount = FirebaseAccount(account: account, _imageLink: imageLink ?? "")
                    fireBaseAccount.saveAccountToFirestore()
                }

            } else {
                let fireBaseAccount = FirebaseAccount(account: account)
                fireBaseAccount.saveAccountToFirestore()
            }

        } else {
            print("sync is off, account")
        }
    }
    
    
    func editAccountInCloud(account: Account) {
        
        let shouldSync = userDefaults.object(forKey: kSYNCTOCLOUD) as? Bool ?? false
        
        if FUser.currentUser() != nil && shouldSync {
            
            if account.image != nil {
                //uploadImage
                uploadImage(account.image!, id: account.id!.uuidString, forExpense: false) { (imageLink) in
                    
                    let fireBaseAccount = FirebaseAccount(account: account, _imageLink: imageLink ?? "")
                    fireBaseAccount.saveAccountToFirestore()
                }

            } else {
                let fireBaseAccount = FirebaseAccount(account: account)
                fireBaseAccount.saveAccountToFirestore()
            }
            
        } else {
            print("sync is off, account edit")
        }
    }
    
    func deleteAccountInCloud(account: Account) {
        
        let shouldSync = userDefaults.object(forKey: kSYNCTOCLOUD) as? Bool ?? false
        
        if FUser.currentUser() != nil && shouldSync {
            
            let fireBaseAccount = FirebaseAccount(account: account)
            fireBaseAccount.deleteAccountFromFirestore()
            
        } else {
            print("sync is off, account delete")
        }
    }
    
    func uploadAllAccountsToCloud(allAccounts: [Account]) {
        
        let shouldSync = userDefaults.object(forKey: kSYNCTOCLOUD) as? Bool ?? false
        
        if FUser.currentUser() != nil && shouldSync {
            
            for account in allAccounts {
                let firAccount = FirebaseAccount(account: account)
                firAccount.saveAccountToFirestore()
            }
            
        } else {
            print("sync is off, upload all accounts")
        }
    }
    

    
    //MARK: - Expenses
    func saveExpenseToCloud(expense: Expense, didChangeReceipt: Bool) {
        
        let shouldSync = userDefaults.object(forKey: kSYNCTOCLOUD) as? Bool ?? false
        
        if FUser.currentUser() != nil && shouldSync {
            
            if expense.image != nil && didChangeReceipt {
                //uploadImage
                uploadImage(expense.image!, id: expense.objectId!, forExpense: true) { (imageLink) in
                    
                    let firebaseExpense = FirebaseExpense(expense: expense, _imageLink: imageLink ?? "")
                    firebaseExpense.saveExpenseToFirestore()
                }

            } else {
                let firebaseExpense = FirebaseExpense(expense: expense)
                firebaseExpense.saveExpenseToFirestore()
            }
            
            
        } else {
            print("Sync is off, expense")
        }
    }
    
    
    func deleteExpenseInCloud(expense: Expense) {
         
         let shouldSync = userDefaults.object(forKey: kSYNCTOCLOUD) as? Bool ?? false
         
         if FUser.currentUser() != nil && shouldSync {
             
             let firebaseExpense = FirebaseExpense(expense: expense)

             firebaseExpense.deleteExpenseFromFirestore()
         } else {
             print("Sync is off, expense")
         }
     }
    
    func uploadAllExpensesToCloud(allExpenses: [Expense]) {
        
        let shouldSync = userDefaults.object(forKey: kSYNCTOCLOUD) as? Bool ?? false
        
        if FUser.currentUser() != nil && shouldSync {
            
            for expense in allExpenses {
                let firExpense = FirebaseExpense(expense: expense)
                firExpense.saveExpenseToFirestore()
            }
            
        } else {
            print("sync is off, upload all accounts")
        }
    }
    
}
