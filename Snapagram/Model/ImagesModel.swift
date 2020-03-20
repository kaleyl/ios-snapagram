//
//  ImagesModel.swift
//  Snapagram
//
//  Created by Kaley Leung on 3/19/20.
//  Copyright © 2020 iOSDeCal. All rights reserved.
//

import Foundation
import UIKit.UIImage
import Firebase
import FirebaseFirestore
import FirebaseStorage


var images = Images()


struct ImageData {
    let image: UIImage
    let timestamp: Date
}

class Images {
    var images: [ImageData] = []
    let db = Firestore.firestore()
    let storage = Storage.storage()
    
    func numImages() -> Int {
           return images.count
    }
    
    func dataFor(index: Int) -> ImageData {
       return images[index]
    }
    
    
    //Firebase Operations
    func fetch(){
        db.collection("images").getDocuments(){ (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
            
                for document in querySnapshot!.documents {
                    let imageID = document.data()["image"] as! String
                    let timeStamp = document.data()["timestamp"] as! Timestamp
                    
                    let date = Date(timeIntervalSince1970: TimeInterval(timeStamp.seconds))
                    let storageRef = self.storage.reference(withPath: "images/\(imageID).jpg")
                    
                    storageRef.getData(maxSize: 4 * 1024 * 1024) { (data, error) in
                        if error != nil {
                            print("error")
                        }
                        if let data = data {
                            let image = UIImage(data: data)
                            print(image!)
                            self.images.append(ImageData(image: image!, timestamp: date))
                            print(self.images.count)
                        }
                    }
                }
            }
        }
    }
    
    
    func add(image: UIImage, timestamp: Date){
        images.append(ImageData(image: image, timestamp: timestamp))
        
        // "images" -> unique image id, timestamp
        let imageID = UUID.init().uuidString
        let dbtimeStammp = Timestamp(date: timestamp)
        
        let storageRef = storage.reference(withPath: "images/\(imageID).jpg")
        guard let imageData = image.jpegData(compressionQuality: 0.75) else { return }
        let uploadMetadata = StorageMetadata.init()
        uploadMetadata.contentType = "image/jpeg"
        storageRef.putData(imageData)
        
        var ref: DocumentReference? = nil
        ref = db.collection("images").addDocument(data: ["image": imageID, "timestamp": dbtimeStammp]) {
            err in
            if let err  = err {
                print("Error adding document: \(err)")
            } else {
                print("Document added with ID: \(ref!.documentID)")
            }
        }
    }
    
   
}
