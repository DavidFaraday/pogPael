//
//  FirebaseAccount.swift
//  WalletApp
//
//  Created by David Kababyan on 18/04/2020.
//  Copyright © 2020 David Kababyan. All rights reserved.
//

import Foundation

class FirebaseAccount {
    
    let objectId: String
    var name: String
    var isCurrent: Bool
    var imageLink: String

    //MARK: - Initializers

    init(account: Account, _imageLink: String = "") {
        
        objectId = account.id?.uuidString ?? ""
        name = account.name ?? ""
        isCurrent = account.isCurrent
        imageLink = _imageLink
    }

    init(_dictionary: NSDictionary) {
        
        objectId = _dictionary[kOBJECTID] as! String
        name = _dictionary[kNAME] as? String ?? ""
        isCurrent = _dictionary[kISCURRENT] as? Bool ?? false
        imageLink = _dictionary[kIMAGELINK] as? String ?? ""
    }

    //MARK: - Saving

    func saveAccountToFirestore() {
        FirebaseReference(.User).document(FUser.currentId()).collection(kACCOUNT_PATH).document(self.objectId).setData(accountDictionaryFrom(account: self) as! [String : Any]) { (error) in
            
            if error != nil {
                print("error saving account, ", error!.localizedDescription)
            }
        }
    }

    //MARK: - Editing

    func updateAccountInFirestore(_ withValues: [String : Any]) {

        FirebaseReference(.User).document(FUser.currentId()).collection(kACCOUNT_PATH).document(self.objectId).updateData(withValues) { (error) in

            if error != nil {
                print("Error updating account, ", error!.localizedDescription)
            }
        }
    }

    //MARK: - Fetching

    class func loadAccounts(completion: @escaping (_ allAccounts: [FirebaseAccount]) -> Void) {
        
        var allAccounts: [FirebaseAccount] = []
        
        FirebaseReference(.User).document(FUser.currentId()).collection(kACCOUNT_PATH).getDocuments { (snapshot, error) in
            
            guard let snapshot = snapshot else {
                completion(allAccounts)
                return
            }
            
            if !snapshot.isEmpty {
                
                for accountSnapshot in snapshot.documents {
                    allAccounts.append(FirebaseAccount(_dictionary: accountSnapshot.data() as NSDictionary))
                }
            }
            
            completion(allAccounts)
        }
    }
    
    //MARK: - Delete

    func deleteAccountFromFirestore() {
        
        FirebaseReference(.User).document(FUser.currentId()).collection(kACCOUNT_PATH).document(self.objectId).delete { (error) in
            
            if error != nil {
                print("error deleting account, ", error!.localizedDescription)
            }
        }
    }

}



//MARK: - Helper funcs
func accountDictionaryFrom(account: FirebaseAccount) -> NSDictionary {
    
    return NSDictionary(objects: [account.objectId,
                                  account.name,
                                  account.isCurrent,
                                  account.imageLink
                        ],
                        forKeys: [kOBJECTID as NSCopying,
                                  kNAME as NSCopying,
                                  kISCURRENT as NSCopying,
                                  kIMAGELINK as NSCopying
                        ])
}
