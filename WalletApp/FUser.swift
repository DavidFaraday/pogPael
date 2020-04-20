//
//  FUser.swift
//  WalletApp
//
//  Created by David Kababyan on 17/04/2020.
//  Copyright © 2020 David Kababyan. All rights reserved.
//

import Foundation
import FirebaseAuth

class FUser {

    let objectId: String
    var email: String


    //MARK: - Initializers
    
    init(_objectId: String, _email: String) {
        
        objectId = _objectId
        email = _email
    }
    
    init(_dictionary: NSDictionary) {
        
        objectId = _dictionary[kOBJECTID] as! String
        email = _dictionary[kEMAIL] as? String ?? ""
    }

    
    //MARK: - Returning current user funcs
     class func currentId() -> String {
         return Auth.auth().currentUser!.uid
     }
     
     class func currentUser () -> FUser? {
         if Auth.auth().currentUser != nil {
             if let dictionary = UserDefaults.standard.object(forKey: kCURRENTUSER) {
                 return FUser.init(_dictionary: dictionary as! NSDictionary)
             }
         }
         return nil
     }

    
    //MARK: - Login function
    class func loginUserWith(email: String, password: String, completion: @escaping (_ error: Error?, _ isEmailVerified: Bool) -> Void) {
        
        Auth.auth().signIn(withEmail: email, password: password) { (authDataResult, error) in
            

            if error == nil {
                if authDataResult!.user.isEmailVerified {
                    
                    downloadUserFromFirebase(userId: authDataResult!.user.uid, email: email, completion: {
                        didSaveLocally in
                        
                        completion(error, didSaveLocally)
                    })
                } else {
                    print("Email is not verified")
                    completion(error, false)
                }
            } else {
                completion(error, false)
            }
        }
    }
    
    
    class func registerUserWith(email: String, password: String, completion: @escaping (_ error: Error?) -> Void ) {
        
        Auth.auth().createUser(withEmail: email, password: password, completion: { (authDataResult, error) in
            
            completion(error)

            if error == nil {
                
                //send verification email
                authDataResult!.user.sendEmailVerification(completion: { (error) in
                    print("auth email sent error is :", error?.localizedDescription)
                })

            }
        })
    }

    //MARK: - Edit User profile
    func updateUserEmail(newEmail: String, completion: @escaping (_ error: Error?) -> Void) {

        Auth.auth().currentUser?.updateEmail(to: newEmail) { (error) in
            if error == nil {

                FUser.resendVerificationEmail(email: newEmail, completion: { (error) in
                    
                })
                completion(error)
            } else {
                print("error updating email\(error!.localizedDescription)")
                completion(error)
            }
        }
    }

    
    //MARK: - Resend link methods
    class func resendVerificationEmail(email: String, completion: @escaping (_ error: Error?) -> Void ) {
        
        Auth.auth().currentUser?.reload(completion: { (error) in

            Auth.auth().currentUser?.sendEmailVerification(completion: { (error) in

                completion(error)
            })
        })
    }

    class func resetPasswordFor(email: String, completion: @escaping (_ error: Error?) -> Void) {
        Auth.auth().sendPasswordReset(withEmail: email) { (error) in
            completion(error)
        }
    }

    
    //MARK: - LogOut func
    class func logOutCurrentUser(completion: @escaping (_ error: Error?) -> Void) {

        do {
            try Auth.auth().signOut()
            
            userDefaults.removeObject(forKey: kCURRENTUSER)
            userDefaults.synchronize()
            completion(nil)
            
        } catch let error as NSError {
            completion(error)
        }
    }
} // end of class


//MARK: - DownloadUser
func downloadUserFromFirebase(userId: String, email: String, completion: @escaping (_ didSaveLocally: Bool) -> Void) {
    
    FirebaseReference(.User).document(userId).getDocument { (snapshot, error) in
        guard let snapshot = snapshot else {  return }
        
        if snapshot.exists {

            saveUserLocally(mUserDictionary: snapshot.data()! as NSDictionary)
        } else {
            //this is the first time user logged in after registration
            let user = FUser(_objectId: userId, _email: email)
            saveUserLocally(mUserDictionary: userDictionaryFrom(user: user))
            saveUserToFirestore(mUser: user)
        }
        
        completion(true)
    }
}

//MARK: - Save user funcs
func saveUserToFirestore(mUser: FUser) {
    FirebaseReference(.User).document(mUser.objectId).setData(userDictionaryFrom(user: mUser) as! [String : Any]) { (error) in
        if error != nil {
            print("error saving user \(error!.localizedDescription)")
        }
    }
}


func saveUserLocally(mUserDictionary: NSDictionary) {
    userDefaults.set(mUserDictionary, forKey: kCURRENTUSER)
    userDefaults.synchronize()
}

//MARK: - Helper funcs
func userDictionaryFrom(user: FUser) -> NSDictionary {
    
    return NSDictionary(objects: [user.objectId,
                                  user.email
                        ],
                        forKeys: [kOBJECTID as NSCopying,
                                  kEMAIL as NSCopying,
                        ])
}

