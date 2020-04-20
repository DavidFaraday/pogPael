//
//  FirebaseExpense.swift
//  WalletApp
//
//  Created by David Kababyan on 18/04/2020.
//  Copyright © 2020 David Kababyan. All rights reserved.
//

import Foundation
import Firebase

class FirebaseExpense {
    
    let objectId: String
    var amount: Double
    var category: String
    var isExpense: Bool
    var nameDescription: String
    var date: Date
    var dateString: String
    var shouldRepeat: Bool
    var weekOfTheYear: String
    var monthOfTheYear: String
    var year: String
    var userId: String
    var notes: String
    var imageLink: String


    //MARK: - Initializers

    init(expense: Expense, _imageLink: String = "") {
        
        objectId = expense.objectId ?? ""
        amount = expense.amount
        category = expense.category ?? ""
        isExpense = expense.isExpense
        nameDescription = expense.nameDescription ?? ""
        date = expense.date ?? Date()
        dateString = expense.dateString ?? ""
        shouldRepeat = expense.shouldRepeat
        weekOfTheYear = expense.weekOfTheYear ?? ""
        monthOfTheYear = expense.monthOfTheYear ?? ""
        year = expense.year ?? ""
        userId = expense.userId?.uuidString ?? ""
        notes = expense.notes ?? ""
        imageLink = _imageLink
    }

    init(_dictionary: NSDictionary) {
        
        objectId = _dictionary[kOBJECTID] as! String
        amount = _dictionary[kAMOUNT] as? Double ?? 0.0
        category = _dictionary[kCATEGORY] as? String ?? ""
        isExpense = _dictionary[kISEXPENSE] as? Bool ?? false
        nameDescription = _dictionary[kNAMEDESCRIPTIOPN] as! String
        date = _dictionary[kDATE] as? Date ?? Date()
        dateString = _dictionary[kDATESTRING] as? String ?? ""
        shouldRepeat = _dictionary[kSHOULDREPEAT] as? Bool ?? false
        weekOfTheYear = _dictionary[kWEEKOFTHEYEAR] as? String ?? ""
        monthOfTheYear = _dictionary[kMONTHOFTHEYEAR] as? String ?? ""
        year = _dictionary[kYEAR] as? String ?? ""
        userId = _dictionary[kUSERID] as? String ?? ""
        notes = _dictionary[kNOTES] as? String ?? ""
        imageLink = _dictionary[kIMAGELINK] as? String ?? ""
    }

    //MARK: - Saving

    func saveExpenseToFirestore() {

        FirebaseReference(.User).document(FUser.currentId()).collection(kEXPENSE_PATH).document(self.objectId).setData(expenseDictionaryFrom(expense: self) as! [String : Any]) { (error) in
            
            if error != nil {
                print("error saving account, ", error!.localizedDescription)
            }
        }
    }


    //MARK: - Fetching

    class func loadExpenses(completion: @escaping (_ allExpenses: [FirebaseExpense]) -> Void) {
        
        var allExpenses: [FirebaseExpense] = []
        
        FirebaseReference(.User).document(FUser.currentId()).collection(kEXPENSE_PATH).getDocuments { (snapshot, error) in
            
            guard let snapshot = snapshot else {
                completion(allExpenses)
                return
            }
            
            if !snapshot.isEmpty {
                
                for expenseSnapshot in snapshot.documents {
                    allExpenses.append(FirebaseExpense(_dictionary: expenseSnapshot.data() as NSDictionary))
                }
            }
            
            completion(allExpenses)
        }
    }
    
    func updateExpenseInFirestore(_ withValues: [String : Any]) {

        FirebaseReference(.User).document(FUser.currentId()).collection(kEXPENSE_PATH).document(self.objectId).updateData(withValues) { (error) in

            if error != nil {
                print("Error updating expense, ", error!.localizedDescription)
            }
        }
    }

    
    //MARK: - Delete

    func deleteExpenseFromFirestore() {
        print("deleting////////")
        print(FirebaseReference(.User).document(FUser.currentId()).collection(kEXPENSE_PATH))
            
            FirebaseReference(.User).document(FUser.currentId()).collection(kEXPENSE_PATH).document(self.objectId).delete { (error) in
            print(".........////////")

            if error != nil {
                print("error deleting account, ", error!.localizedDescription)
            }
        }
    }

}



//MARK: - Helper funcs
func expenseDictionaryFrom(expense: FirebaseExpense) -> NSDictionary {
    
    return NSDictionary(objects: [expense.objectId,
                                  expense.amount,
                                  expense.category,
                                  expense.isExpense,
                                  expense.nameDescription,
                                  expense.date,
                                  expense.dateString,
                                  expense.shouldRepeat,
                                  expense.weekOfTheYear,
                                  expense.monthOfTheYear,
                                  expense.year,
                                  expense.userId,
                                  expense.notes,
                                  expense.imageLink
                                  
                        ],
                        forKeys: [kOBJECTID as NSCopying,
                                  kAMOUNT as NSCopying,
                                  kCATEGORY as NSCopying,
                                  kISEXPENSE as NSCopying,
                                  kNAMEDESCRIPTIOPN as NSCopying,
                                  kDATE as NSCopying,
                                  kDATESTRING as NSCopying,
                                  kSHOULDREPEAT as NSCopying,
                                  kWEEKOFTHEYEAR as NSCopying,
                                  kMONTHOFTHEYEAR as NSCopying,
                                  kYEAR as NSCopying,
                                  kUSERID as NSCopying,
                                  kNOTES as NSCopying,
                                  kIMAGELINK as NSCopying
                        ])
}
