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
var dbRef: DatabaseReference = Database.database().reference()

class Thread {
    var name: String
    var emoji: String
    var entries: [ThreadEntry]
    
    init(name: String, emoji: String) {
        self.name = name
        self.emoji = emoji
        self.entries = []
    }
    
    func addEntry(threadEntry: ThreadEntry) {
        entries.append(threadEntry)
    }
    
    func removeFirstEntry() -> ThreadEntry? {
        if entries.count > 0 {
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
        for thread in threads {
            let entry = ThreadEntry(username: self.username, image: UIImage(named: "garbers")!)
            thread.addEntry(threadEntry: entry)
            threadNames.append(thread.name)
            images.add(image: UIImage(named: "garbers")!, timestamp: Date())
        }
    }
    
    func addPost(post: Post) {
        posts.append(post)
        
        //add post to DataBase
        guard let key = dbRef.child("posts").childByAutoId().key else { return }
        
        let post = ["location": post.location,
                    "username": feed.username,
                    "caption": post.caption,
            ] as [String : Any]
        
        let childUpdates = ["/posts/\(key)": post]
        dbRef.updateChildValues(childUpdates)
    }
    
    
    
    
    func fetchPost(){
        let imageData = images.dataFor(index: (images.images.count - 1)).image
        let date = images.dataFor(index: (images.images.count - 1)).timestamp

        let refHandle = dbRef.observe(DataEventType.value, with: { (snapshot) in
          let postDict = snapshot.value as? [String : AnyObject] ?? [:]
            self.posts.append( Post(location: postDict["location"] as! String, image: imageData
                , user: postDict["username"] as! String, caption: postDict["caption"] as! String, date: date
            ))
        })
    }
    
    // Optional: Implement adding new threads!
    func addThread(thread: Thread) {
        threads.append(thread)
        threadNames.append(thread.name)
    }
    
}

// write firebase functions here (pushing, pulling, etc.)

