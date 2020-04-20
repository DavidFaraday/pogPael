//
//  CoreDataManager.swift
//  WalletApp
//
//  Created by David Kababyan on 24/03/2020.
//  Copyright © 2020 David Kababyan. All rights reserved.
//

import Foundation
import CoreData
import UIKit


class CoreDataManager {
    
    static let sharedManager = CoreDataManager()
    
    private init() {}
    
    //MARK: - Accounts

    func saveFirebaseAccountsToCD(firebaseAccounts: [FirebaseAccount]) {
        
        for firAccount in firebaseAccounts {
            self.saveAccountFrom(firAccount: firAccount)
        }
    }
    
    func saveAccountFrom(firAccount: FirebaseAccount) {
        
        let context = AppDelegate.context
        let account = Account(context: context)
        account.id = UUID(uuidString: firAccount.objectId)
        account.name = firAccount.name
        account.isCurrent = firAccount.isCurrent
        

        if firAccount.imageLink != "" {
            
            downloadImage(imageUrl: firAccount.imageLink) { (accountImage) in
                if accountImage != nil {
                    account.image = accountImage!.jpegData(compressionQuality: 1.0)
                }
            }
        }
        
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
    }
    
    //MARK: - Expenses
        func saveFirebaseExpensesToCD(firebaseExpenses: [FirebaseExpense]) {
            
            for firExpense in firebaseExpenses {
                self.saveExpenseFrom(firExpense: firExpense)
            }
        }
        
        func saveExpenseFrom(firExpense: FirebaseExpense) {
            
            let context = AppDelegate.context
            let expense = Expense(context: context)
            expense.objectId = firExpense.objectId
            expense.amount = firExpense.amount
            expense.category = firExpense.category
            expense.isExpense = firExpense.isExpense
            expense.nameDescription = firExpense.nameDescription
            expense.date = firExpense.date
            expense.dateString = firExpense.dateString
            expense.shouldRepeat = firExpense.shouldRepeat
            expense.weekOfTheYear = firExpense.weekOfTheYear
            expense.monthOfTheYear = firExpense.monthOfTheYear
            expense.year = firExpense.year
            expense.userId = UUID(uuidString: firExpense.userId)
            expense.notes = firExpense.notes
            
            if firExpense.imageLink != "" {

                downloadImage(imageUrl: firExpense.imageLink) { (expenseImage) in
                    if expenseImage != nil {
                        expense.image = expenseImage!.jpegData(compressionQuality: 1.0)
                    }
                }
            }

            
            (UIApplication.shared.delegate as! AppDelegate).saveContext()
        }

    
}
