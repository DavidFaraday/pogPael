//
//  File.swift
//  WalletApp
//
//  Created by David Kababyan on 27/03/2020.
//  Copyright © 2020 David Kababyan. All rights reserved.
//

import Foundation
import CoreData

class UserAccount {
    
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
}
