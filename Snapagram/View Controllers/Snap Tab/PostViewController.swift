//
//  PostViewController.swift
//  Snapagram
//
//  Created by Kaley Leung on 3/19/20.
//  Copyright © 2020 iOSDeCal. All rights reserved.
//

import UIKit
import Firebase

class PostViewController: UIViewController, UITextFieldDelegate, UICollectionViewDelegate, UICollectionViewDataSource {
    
    
    @IBOutlet weak var toThreadLabel: UILabel!
    
    @IBOutlet weak var captionField: UITextField!
    
    @IBOutlet weak var locationField: UITextField!
    
    @IBOutlet weak var postButton: UIButton!
    
    @IBOutlet weak var imagePreview: UIImageView!
    
    @IBOutlet weak var threadChoiceCollectionView: UICollectionView!
    
    @IBOutlet weak var toFeedLabel: UILabel!
    
    @IBOutlet weak var newThreadButton: UIButton!
    
    var imageToDisplay: UIImage!
    
    
  
    
    override func viewDidLoad() {
        super.viewDidLoad()
        threadChoiceCollectionView.delegate = self
        threadChoiceCollectionView.dataSource = self
        
        captionField.delegate = self
        locationField.delegate = self
        
        imageToDisplay = images.dataFor(index: (images.images.count - 1)).image
        imagePreview.image = imageToDisplay
        
        newThreadButton.layer.cornerRadius = 5
        newThreadButton.layer.borderWidth = 1
        
        // get data from firebase
        //images.fetch()
    }


    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true;
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        threadChoiceCollectionView.reloadData()
     }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return feed.threads.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let index = indexPath.item
        let thread = feed.threads[index]
        
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ThreadChoiceCell", for: indexPath) as? ChooseThreadCollectionViewCell {
            cell.emojiButton.text = thread.emoji
            cell.nameLabel.text = thread.name
            return cell
        } else {
            return UICollectionViewCell()
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let chosenThread = feed.threads[indexPath.item]
        let newEntry = ThreadEntry(username: feed.username, image: imageToDisplay)
        
        chosenThread.addEntry(threadEntry: newEntry)
        self.imagePreview.image = nil
        
        self.navigationController?.popViewController(animated: true)
    }

    
    @IBAction func postButtonPressed(_ sender: Any) {
        //add Post to feed instance
        let caption: String = captionField.text!
        let location: String = locationField.text ?? ""
        let newPost = Post(location: location, image: images.dataFor(index: (images.images.count - 1)).image, user: feed.username, caption: caption, date: Date())
        feed.addPost(post: newPost)
        
        //reload view
        self.imagePreview.image = nil
        
        self.navigationController?.popViewController(animated: true)
    }
    
    
    
    @IBAction func newThreadButtonPressed(_ sender: Any) {
        let alert = UIAlertController(title: "Make a new Thread",
         message: "Insert new thread name and Emoji!",
         preferredStyle: .alert)
        
        alert.addTextField { (textField: UITextField) in
            textField.keyboardAppearance = .dark
            textField.keyboardType = .default
            textField.autocorrectionType = .default
            textField.placeholder = "Enter new Thread Name"
            textField.textColor = UIColor.systemGray
        }
        
        alert.addTextField { (textField: UITextField) in
           textField.keyboardAppearance = .dark
           textField.keyboardType = .default
           textField.autocorrectionType = .default
           textField.placeholder = "Enter new Thread Emoji"
           textField.textColor = UIColor.systemGray
        }
        
        
        let createAction = UIAlertAction(title: "Create new Thread", style: .default, handler: { (action) -> Void in
            let threadName = alert.textFields![0].text
            let threadEmoji = alert.textFields![1].text
            
            
            if (threadEmoji!.count > 1) {
                self.presentAlertViewController(title: "Opps", message: "Enter a Single Emoji!")
            }
            
            if (threadName == "" || threadEmoji == "") {
                self.presentAlertViewController(title: "Opps", message: "Thread Name/Emoji cannot be empty!")
            }
            
            if (feed.threadNames.contains(threadName!)) {
                self.presentAlertViewController(title: "Opps", message: "The thread already exists!")
            }
            else {
                let newThread = Thread(name: threadName!, emoji: threadEmoji!)
                feed.addThread(thread: newThread)
                self.viewWillAppear(false)
            }
        })
        
        let cancel = UIAlertAction(title: "Cancel", style: .destructive, handler: { (action) -> Void in })
        
        alert.addAction(createAction)
        alert.addAction(cancel)
        present(alert, animated: true, completion: nil)
            
    }
    
    
    func presentAlertViewController(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "Okay", style: .default) { (action) in
            self.dismiss(animated: true, completion: nil)
        }
        alertController.addAction(action)
        present(alertController, animated: true, completion: nil)
    }
    
}

