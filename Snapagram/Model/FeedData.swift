//
//  FeedData.swift
//  Snapagram
//
//  Created by Arman Vaziri on 3/8/20.
//  Copyright © 2020 iOSDeCal. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import FirebaseStorage
import FirebaseDatabase



// Create global instance of the feed
var feed = FeedData()
//firebase
let db = Firestore.firestore()
var dbRef: DatabaseReference = Database.database().reference()
var storage: Storage = Storage.storage()

class Thread {
    var name: String
    var emoji: String
    var entries: [ThreadEntry]
    var entriesID = [String]()
    
    init(name: String, emoji: String) {
        self.name = name
        self.emoji = emoji
        self.entries = []
    }
    
    func addEntry(threadEntry: ThreadEntry) {
        entries.append(threadEntry)
        
        let imageID = UUID.init().uuidString
        let storageRef = storage.reference(withPath: "entries/\(imageID).jpg")
        guard let imageData = threadEntry.image.jpegData(compressionQuality: 0.75) else { return }
        let uploadMetadata = StorageMetadata.init()
        uploadMetadata.contentType = "image/jpeg"
        storageRef.putData(imageData)

        var ref: DocumentReference? = nil
        ref = db.collection("threads").document("\(self.name)").collection("entries").addDocument(data:
            [ "image" : imageID ])
        { err in
               if let err  = err {
               print("Error adding document: \(err)")
           } else {
                self.entriesID.append(ref!.documentID)
               print("Document added with ID: \(ref!.documentID)")
           }
        }
    
    }
    
    
    func removeFirstEntry() -> ThreadEntry? {
        if entries.count > 0 {
            let firEntry = entriesID[0]
            db.collection("threads").document("\(self.name)").collection("entries").document(firEntry).delete()
            entriesID.removeFirst()
            return entries.removeFirst()
        }
        return nil
    }
    
    func unreadCount() -> Int {
        return entries.count
    }
}

struct ThreadEntry {
    var username: String
    var image: UIImage
}

struct Post {
    var location: String
    var image: UIImage?
    var user: String
    var caption: String
    var date: Date
}

class FeedData {
    var username = "kkale.yi"
    
    var threads: [Thread] = [
        Thread(name: "memes", emoji: "😂"),
        Thread(name: "dogs", emoji: "🐶"),
        Thread(name: "fashion", emoji: "🕶"),
        Thread(name: "fam", emoji: "👨‍👩‍👧‍👦"),
        Thread(name: "tech", emoji: "💻"),
        Thread(name: "eats", emoji: "🍱"),
    ]
    
    var threadNames : [String] = []

    // Adds dummy posts to the Feed
    var posts: [Post] = [
        Post(location: "New York City", image: UIImage(named: "skyline"), user: "nyerasi", caption: "Concrete jungle, wet dreams tomato 🍅 —Alicia Keys", date: Date()),
        Post(location: "Memorial Stadium", image: UIImage(named: "garbers"), user: "rjpimentel", caption: "Last Cal Football game of senior year!", date: Date()),
        Post(location: "Soda Hall", image: UIImage(named: "soda"), user: "chromadrive", caption: "Find your happy place 💻", date: Date())
    ]
    
    
    // Adds dummy data to each thread
    init() {
        self.username = "kaleyi"

        for thread in threads {
            let entry = ThreadEntry(username: self.username, image: UIImage(named: "garbers")!)
            thread.addEntry(threadEntry: entry)
            threadNames.append(thread.name)
        }
        
    }
    
    func addPost(post: Post) {
        posts.append(post)
        
        let imageID = UUID.init().uuidString
        let dbtimeStamp = Timestamp(date: post.date)

        let storageRef = storage.reference(withPath: "posts/\(imageID).jpg")
        guard let imageData = post.image!.jpegData(compressionQuality: 0.75) else { return }
        let uploadMetadata = StorageMetadata.init()
        uploadMetadata.contentType = "image/jpeg"
        storageRef.putData(imageData)

        var ref: DocumentReference? = nil
        ref = db.collection("posts").addDocument(data:
            [   "date" : dbtimeStamp,
                        "location": post.location,
                         "pathToImage": imageID,
                         "username": username,
                         "caption": post.caption,
            ]) { err in
                if let err  = err {
                print("Error adding document: \(err)")
            } else {
                print("Document added with ID: \(ref!.documentID)")
            }
        }
    }

    
    func fetchPost(){
        db.collection("posts").getDocuments(){ (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    let location = document.data()["location"] as! String
                    let username = document.data()["username"] as! String
                    let imageID = document.data()["pathToImage"] as! String
                    let caption = document.data()["caption"] as! String
                    let timeStamp = document.data()["date"] as! Timestamp

                    let date = Date(timeIntervalSince1970: TimeInterval(timeStamp.seconds))

                    let storageRef = storage.reference(withPath: "posts/\(imageID).jpg")

                    storageRef.getData(maxSize: 4 * 1024 * 1024) { (data, error) in
                        if error != nil {
                            print("error")
                        }
                        if let data = data {
                            let image = UIImage(data: data)
                            print(image!)
                            images.images.append(ImageData(image: image!, timestamp: date))
                            print(images.numImages())

                            let newPost = Post(location: location, image: image, user: username, caption: caption, date: date)
                            
                            self.posts.append(newPost)
                            print(self.posts.count)
                            
                        }
                    }
                }

            }
        }

    }
    
    
    
    
    // Optional: Implement adding new threads!
    func addThread(thread: Thread) {
        threads.append(thread)
        threadNames.append(thread.name)
        var ref: DocumentReference? = nil
        ref = db.collection("threads").document("\(thread.name)").collection("info").addDocument(data:
            [   "name" : thread.name,
                "emoji": thread.emoji
          ]) { err in
              if let err  = err {
              print("Error adding document: \(err)")
          } else {
              print("Document added with ID: \(ref!.documentID)")
          }
      }
    }
    
}

// write firebase functions here (pushing, pulling, etc.)

