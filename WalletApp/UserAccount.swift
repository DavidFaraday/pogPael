//
//  File.swift
//  WalletApp
//
//  Created by David Kababyan on 27/03/2020.
//  Copyright © 2020 David Kababyan. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class UserAccount {
    
    class func createAccount(name: String, image: UIImage?, iD: UUID) {
        
        let context = AppDelegate.context
        let account = Account(context: context)
        account.id = iD
        account.name = name
        account.isCurrent = true
        
        if image != nil {
            account.image = image!.jpegData(compressionQuality: 0.5)
        }
        
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
        
    }
    
    class func currentAccount() -> Account? {
        
        let context = AppDelegate.context

        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Account")
        fetchRequest.sortDescriptors = []
        fetchRequest.predicate = NSPredicate(format: "isCurrent = %i", true)
        
        var account: NSManagedObject?
        
        do {
            account = try context.fetch(fetchRequest).first as? NSManagedObject
        } catch {
            print("Failed to fetch account")
        }
        
        return account as? Account
    }
    
    class func changeAccountStatus() {
        
        let context = AppDelegate.context

        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Account")
        fetchRequest.sortDescriptors = []
        fetchRequest.predicate = NSPredicate(format: "isCurrent = %i", true)
        

        do {
            let accounts = try context.fetch(fetchRequest)
            
            for account in accounts {
                let tempAccount = account as! Account
                tempAccount.isCurrent = false
                
            }
            
            (UIApplication.shared.delegate as! AppDelegate).saveContext()
        } catch {
            print("Failed to fetch account")
        }
    }
}
