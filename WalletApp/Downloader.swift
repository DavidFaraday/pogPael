//
//  Downloader.swift
//  WalletApp
//
//  Created by David Kababyan on 20/04/2020.
//  Copyright © 2020 David Kababyan. All rights reserved.
//

import Foundation
import FirebaseStorage

let storage = Storage.storage()

func uploadImage(_ imageData: Data, id: String, forExpense: Bool, completion: @escaping (_ imageLink: String?) -> Void) {
    
    if Reachability.HasConnection() {
        
        let currentFileName = id + ".jpg"
        
        let folderName = forExpense ? "Receipts" : "Account"
        
        let fileName = FUser.currentId() + "/" + folderName + "/" + currentFileName
        
        let storageRef = storage.reference(forURL: kFILEREFERENCE).child(fileName)
                
        var task : StorageUploadTask!
                
        
        task = storageRef.putData(imageData, metadata: nil, completion: {
            metadata, error in
            
            task.removeAllObservers()
            
            if error != nil {
                
                print("error uploading document \(error!.localizedDescription)")
                return
            }
            
            storageRef.downloadURL(completion: { (url, error) in
                
                guard let downloadUrl = url else {
                    completion(nil)
                    return
                }
                completion(downloadUrl.absoluteString)
            })
            
        })
        
        saveFileLocally(fileName: currentFileName, fileData: imageData)

    } else {
        print("No Internet Connection!")
    }
}


func downloadImage(imageUrl: String, completion: @escaping (_ image: UIImage?) -> Void) {
    
    let documentURL = URL(string: imageUrl)
    
    let imageFileName = (imageUrl.components(separatedBy: "%").last!).components(separatedBy: "?").first!
    
    
    if fileExistsAtPath(path: imageFileName) {

        if let contentsOfFile = UIImage(contentsOfFile: fileInDocumentsDirectory(filename: imageFileName)) {
            completion(contentsOfFile)
        } else {

            completion(nil)
        }
        
    } else {
        
        let dowloadQueue = DispatchQueue(label: "imageDownloadQueue")

        dowloadQueue.async {
            
            let data = NSData(contentsOf: documentURL!)
            
            if data != nil {
                            
                let imageToReturn = UIImage(data: data! as Data)
                
                DispatchQueue.main.async {
                    completion(imageToReturn!)
                }
                
                saveFileLocally(fileName: imageFileName, fileData: data as Data?)
                
                
            } else {
                DispatchQueue.main.async {
                    print("No document in database")
                    completion(nil!)
                }
            }
        }
    }
}

func saveFileLocally(fileName: String, fileData: Data?) {

    if fileData != nil {
        
        var docURL = getDocumentsURL()
        
        docURL = docURL.appendingPathComponent(fileName, isDirectory: false)
        let data = NSData(data: fileData!)
        data.write(to: docURL, atomically: true)
    }
}

//Helpers
func fileInDocumentsDirectory(filename: String) -> String {
    
    let fileURL = getDocumentsURL().appendingPathComponent(filename)
    return fileURL.path
}

func getDocumentsURL() -> URL {
    
    let documentURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last

    return documentURL!
}

func fileExistsAtPath(path: String) -> Bool {
    
    var doesExist = false
    
    let filePath = fileInDocumentsDirectory(filename: path)
    let fileManager = FileManager.default
    
    if fileManager.fileExists(atPath: filePath) {
        doesExist = true
    } else {
        doesExist = false
    }
    
    return doesExist
}
