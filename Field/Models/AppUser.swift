//
//  AppUser.swift
//  Field
//
//  Created by amyz on 5/9/21.
//

import Foundation
import Firebase


class AppUser{
    var displayName: String
    var intro: String
    var photoURL: String
    var image: UIImage
    var documentID:String
    
    init(displayName:String,intro:String,photoURL: String,image: UIImage, documentID:String){
        self.displayName=displayName
        self.intro=intro
        self.photoURL = photoURL
        self.image=image
        self.documentID = documentID
    }
    
    var dictionary: [String:Any]{
        return ["displayName":displayName,"intro":intro,"photoURL":photoURL]
    }
    
    
    convenience init(user:User){
        self.init(displayName:"",intro:"",photoURL:"",image: UIImage(named: "logo")!, documentID:user.uid)
    }
    convenience init(userid:String){
        self.init(displayName:"",intro:"", photoURL:"", image: UIImage(named: "logo")!, documentID:userid)
    }
    
    convenience init(dictionary: [String:Any]){
        let displayName=dictionary["displayName"] as! String? ?? ""
        let intro=dictionary["intro"] as! String? ?? ""
        let photoURL=dictionary["photoURL"] as! String? ?? ""
        
        self.init(displayName:displayName,intro:intro,photoURL:photoURL, image:UIImage(named: "logo")!,documentID:"")
        
    }
    
    func saveIfNewUser(completion: @escaping(Bool)->()){
        let db = Firestore.firestore()
        let userRef = db.collection("users").document(documentID)
        userRef.getDocument { (document, error) in
            guard error == nil else {
                print("ERROR: couldn't access document for user \(self.documentID)")
                return completion(false)
            }
            guard document?.exists == false else{
                print("The document for user \(self.documentID) already exists. No need to recreate.")
                return completion(true)
            }
            
            let dataToSave: [String: Any] = self.dictionary
            db.collection("users").document(self.documentID).setData(dataToSave){ (error) in
                guard error == nil else{
                    print("ERROR:\(error!.localizedDescription), couldn't save data for \(self.documentID)")
                    return completion(true)
                }
                return completion(true)
            }
        }
    }
    
    func saveData(completion:@escaping (Bool)->()){
        let db = Firestore.firestore()
        
        
        let storage=Storage.storage()
        
        //convert photo.image to jpeg
        guard let photoData=self.image.jpegData(compressionQuality: 0.5) else {
            print("ERROR:couldn't convert photo.image to data")
            return
        }
        
        let  uploadMetaData = StorageMetadata()
        uploadMetaData.contentType="image/jpeg"
        
        //create filename
        if documentID == ""{
            documentID=UUID().uuidString
            
        }
        
        let storageRef=storage.reference().child(documentID)
        
        
        let uploadTask=storageRef.putData(photoData, metadata: uploadMetaData) { (metadata, error) in
            if let error = error{
                print("ERROR:upload your ref \(uploadMetaData) failed. \(error.localizedDescription)")
            }
            
            completion(true)
        }
        
        uploadTask.observe(.success) { (snapshot) in
            print("upload to Firebase storage successful")
            storageRef.downloadURL { (url, error) in
                guard error == nil else {
                    print("ERROR: couldn't create a download url \(error!.localizedDescription)")
                    return completion(false)
                }
                
                guard let url = url else{
                    print("ERROR: url is nil \(error!.localizedDescription)")
                    return completion(false)
                }
                self.photoURL = "\(url)"
                
                let dataToSave = self.dictionary
                let ref = db.collection("users").document(self.documentID)
                ref.setData(dataToSave) { (error) in
                    guard error == nil else {
                        print("ERROR: updating document \(error!.localizedDescription)")
                        return completion(false)
                    }
                    print("Updated document: \(self.documentID)" )
                    completion(true)
                }
            }
        }
        
        uploadTask.observe(.failure) { (snapshot) in
            if let error = snapshot.error {
                print("ERROR:upload task for file \(self.documentID) failed, with error  \(error.localizedDescription)")
            }
            
            completion(false)
        }
    }
        
        
        
        
        func loadData(id: String,completed: @escaping()->()){
            let db=Firestore.firestore()
            
            let ref=db.collection("users").document(id)
            
            ref.getDocument { (document, error) in
                if let error = error {
                    print("ERROR: \(error.localizedDescription)")
                    return completed()
                }
                
                if let document=document, document.exists{
                    let appUser=AppUser(dictionary: document.data()!)
                    self.displayName=appUser.displayName
                    
                    self.intro=appUser.intro
                    
                }else{
                    print("document DNE")
                }
                
                completed()
            }
            
        }
        
        func loadImage(completion: @escaping (Bool) -> ()) {
            
            let db=Firestore.firestore()
            let ref=db.collection("users").document(self.documentID)
            ref.getDocument { (document, error) in
                if let error = error {
                    print("ERROR: \(error.localizedDescription)")
                    return completion(false)
                }
                if let document=document, document.exists{
                    let userPhoto=AppUser(dictionary: document.data()!)
                    self.photoURL=userPhoto.photoURL
                }
                
            }
            
            let storage = Storage.storage()
            let storageRef = storage.reference().child(documentID)
            storageRef.getData(maxSize: 25 * 1024 * 1024) { (data, error) in
                if let error = error {
                    print("ERROR: an error occurred while reading data from file ref: \(storageRef) error = \(error.localizedDescription)")
                    return completion(false)
                } else {
                    
                    self.image = UIImage(data: data!) ?? UIImage()
                    return completion(true)
                }
            }
        }
        
    }


