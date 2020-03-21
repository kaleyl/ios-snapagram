//
//  CameraViewController.swift
//  Snapagram
//
//  Created by RJ Pimentel on 3/11/20.
//  Copyright © 2020 iOSDeCal. All rights reserved.
//

import UIKit

class CameraViewController: UIViewController {

    @IBOutlet weak var cameraButton: UIButton!
    
    @IBOutlet weak var photoLibraryButton: UIButton!
    
    @IBOutlet weak var previewImage: UIImageView!

    @IBOutlet weak var postButton: UIButton!
    
    //var images: Images!
    var imageToDisplay: UIImage!
    var imagePickerController: UIImagePickerController!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        //self.images = Images()
        self.imagePickerController = UIImagePickerController()
        self.imagePickerController.delegate = self
        self.imagePickerController.sourceType = .photoLibrary
        postButton.isHidden = true
        setUp()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        postButton.isHidden = true
    }
    
    func setUp() -> Void {
        
        photoLibraryButton.backgroundColor = Constants.snapagramBlue
        photoLibraryButton.titleLabel?.textColor = UIColor.systemYellow
        photoLibraryButton.layer.cornerRadius = 15
        
        cameraButton.backgroundColor = Constants.snapagramBlue
        cameraButton.titleLabel?.textColor = UIColor.systemYellow
        cameraButton.layer.cornerRadius = 15
    }

    
    @IBAction func postButtonPressed(_ sender: UIButton) {
        self.previewImage.image = nil
        performSegue(withIdentifier: "postSeg", sender: sender)
    }
    
    
    
    @IBAction func camerButtonPressed(_ sender: Any) {
        self.imagePickerController.sourceType = .camera
        present(imagePickerController, animated: true, completion: nil)
    }
    
    @IBAction func LibraryButtonPressed(_ sender: Any) {
         self.imagePickerController.sourceType = .photoLibrary
        present(imagePickerController, animated: true, completion: nil)
        
    }
}

extension CameraViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.originalImage] as? UIImage{
            let currTime = Date()
            images.add(image: image, timestamp: currTime)
            previewImage.image = image
            postButton.isHidden = false
        }
        imagePickerController.dismiss(animated: true, completion: nil)
    }
    
}
