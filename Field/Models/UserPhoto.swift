//
//  UserPhoto.swift
//  Field
//
//  Created by amyz on 5/13/21.
//


import UIKit
import Firebase

class UserPhoto{
    var image: UIImage
    var photoURL: String
    var documentID: String
    
    var dictionary: [String: Any] {
        return["photoURL":photoURL]
    }
    
    init(image: UIImage,photoURL:String,documentID:String){
        self.image=image
        self.photoURL=photoURL
        self.documentID=documentID
    }
    
    convenience init(){
        self.init(image: UIImage(),photoURL: "", documentID: "")
    }
    
    convenience init(dictionary: [String: Any]) {
        let photoURL = dictionary["photoURL"] as! String? ?? ""
        self.init(image: UIImage(),photoURL:photoURL,documentID:"")
    }
    
    func saveData(appUser:AppUser, completion: @escaping (Bool) -> () ){
        let db=Firestore.firestore()
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
        
        let storageRef=storage.reference().child(appUser.documentID).child(documentID)
        
        
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
                let ref = db.collection("users").document(appUser.documentID).collection("profilePicture").document(self.documentID)
                ref.setData(dataToSave) { (error) in
                    guard error == nil else {
                        print("ERROR: updating document \(error!.localizedDescription)")
                        return completion(false)
                    }
                    print("Updated document: \(self.documentID) in user: \(appUser.documentID)")
                    completion(true)
                }
            }
        }
        
        uploadTask.observe(.failure) { (snapshot) in
            if let error = snapshot.error {
                print("ERROR:upload task for file \(self.documentID) failed, in user \(appUser.documentID), with error  \(error.localizedDescription)")
            }
            
            completion(false)
        }
        
    }
    
//    func loadContent(appUser:AppUser, completion: @escaping (Bool) -> ()) {
//        guard appUser.documentID != "" else {
//            print("ERROR: did not pass a valid user into loadImage")
//            return
//        }
//
//        let db=Firestore.firestore()
//        let ref=db.collection("users").document(appUser.documentID).collection("profilePicture").document(self.documentID)
//        ref.getDocument { (document, error) in
//            if let error = error {
//                print("ERROR: \(error.localizedDescription)")
//                return completion(false)
//            }
//            if let document=document, document.exists{
//                let userPhoto=UserPhoto(dictionary: document.data()!)
//                self.photoURL=userPhoto.photoURL
//            }
//
//        }
//
//        let storage = Storage.storage()
//        let storageRef = storage.reference().child(appUser.documentID).child(documentID)
//        storageRef.getData(maxSize: 25 * 1024 * 1024) { (data, error) in
//            if let error = error {
//                print("ERROR: an error occurred while reading data from file ref: \(storageRef) error = \(error.localizedDescription)")
//                return completion(false)
//            } else {
//
//                self.image = UIImage(data: data!) ?? UIImage()
//                return completion(true)
//            }
//        }
//
//
//    }
    
    func loadImage(appUser:AppUser, completion: @escaping (Bool) -> ()) {
        guard appUser.documentID != "" else {
            print("ERROR: did not pass a valid user into loadImage")
            return
        }
        
        let db=Firestore.firestore()
        let ref=db.collection("users").document(appUser.documentID).collection("profilePicture").document(self.documentID)
        ref.getDocument { (document, error) in
            if let error = error {
                print("ERROR: \(error.localizedDescription)")
                return completion(false)
            }
            if let document=document, document.exists{
                let userPhoto=UserPhoto(dictionary: document.data()!)
                self.photoURL=userPhoto.photoURL
            }
            
        }
        
        let storage = Storage.storage()
        let storageRef = storage.reference().child(appUser.documentID).child(documentID)
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
