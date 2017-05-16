//
//  FIRViewController.swift
//  firebase_ios
//
//  Created by Idelfonso Gutierrez Jr. on 5/16/17.
//  Copyright © 2017 Idelfonso Gutierrez Jr. All rights reserved.
//

import UIKit
import Firebase

class FIRViewController: UIViewController {

    // MARK: Properties
    
    var ref: FIRDatabaseReference!
    var message: [FIRDataSnapshot]! = []
    var msglength: NSNumber = 1000
    var storageRef: FIRStorageReference!
    let imageCache = NSCache<NSString, UIImage>()
    var keyboardOnScreen = false
    var placeholderImage = UIImage(named: "ic_account_circle")
    fileprivate var _refHandle: FIRDatabaseHandle!
    var displayName = "Anonymous"
    
    //MARK: IBOutlets
    
    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var textView: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        configureDatabase()
        configureStorage()
    }
    
    deinit {
        ref.child("messages").removeObserver(withHandle: _refHandle)
    }


    //MARK: Configure Firebase
    
    func configureDatabase() {
        // Get reference
        ref = FIRDatabase.database().reference()
        
        // Datbase Observer
        _refHandle = ref.child("messages").observe(.childAdded) { (snapshot: FIRDataSnapshot)in
            self.message.append(snapshot)
            
            //Update Label, Image View
            var snapshot = self.message[self.message.count - 1].value as! [String: String]
            
            if let message = snapshot["message"] {
                DispatchQueue.main.async {
                    self.textLabel.text =  message
                }
            }
            
            if let imageUrl = snapshot["imageUrl"] {
                // download image data
                FIRStorage.storage().reference(forURL: imageUrl).data(withMaxSize: INT64_MAX){ (data, error) in
                    
                    let messageImage = UIImage.init(data: data!, scale: 50)
                    DispatchQueue.main.async {
                        self.imageView?.image = messageImage
                    }
                }
            }
        }
    }
    
    func configureStorage() {
        // Get reference
        storageRef = FIRStorage.storage().reference()
    }
    
    //MARK: IBActions
    @IBAction func sendMessage(_ sender: UIButton) {
        var mdata: [String: Any] = [:]
        mdata["message"] = textView.text ?? "[message]"
        sendJSON(data: mdata)
    }
    
    func sendJSON(data: [String: Any]) {
        
        //Send JSON
        ref.child("messages").childByAutoId().setValue(data) //closure ahead
        
        //Send Image
        if let photo = UIImage(named: "reports"), let photoData = UIImageJPEGRepresentation(photo, 0.8) {
            sendPhotoMessage(photoData: photoData)
        }
    }
    
    func sendPhotoMessage(photoData: Data) {
        let imagePath = "yp_photos/reports.jpg"
        
        // set content type to “image/jpeg” in firebase storage metadata
        let metadata = FIRStorageMetadata()
        metadata.contentType = "image/jpeg"
        
        storageRef.child(imagePath).put(photoData, metadata: metadata) { (metadata, error) in
            if let error = error {
                print("Error uploading: \(error)")
                return
            }
            // use sendMessage to add imageURL to database
            self.sendJSON(data: ["imageUrl": self.storageRef!.child((metadata?.path)!).description])
        }
    }

}

