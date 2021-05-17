//
//  Post.swift
//  Field
//
//  Created by amyz on 5/13/21.
//

import Foundation
import Firebase

class Post{
    var title: String
    var body: String
    
    var hasImage: Bool
    var hashtag: String
    var postUserID: String
    var date: Date
    var documentID: String
    var numberOfLikes: Int
    var image: UIImage
    var photoURL: String
    
    var dictionary: [String: Any] {
        let timeIntervalDate = date.timeIntervalSince1970
        return ["title": title, "body": body, "hasImage": hasImage, "hashtag": hashtag, "postUserID": postUserID, "date": timeIntervalDate,"numberOfLikes":numberOfLikes,"photoURL":photoURL]
    }
    
    init(title: String, body: String, hasImage: Bool,hashtag: String, postUserID: String, date: Date,numberOfLikes:Int, image: UIImage, photoURL: String, documentID: String) {
        self.title = title
        self.body = body
        self.hasImage = hasImage
        self.postUserID = postUserID
        self.hashtag = hashtag
        self.date = date
        self.numberOfLikes=numberOfLikes
        self.image=image
        self.photoURL=photoURL
        self.documentID = documentID
        
    }
    
    convenience init() {
        let postUserID = Auth.auth().currentUser?.uid ?? ""
        self.init(title: "", body: "", hasImage: false,hashtag: "", postUserID: postUserID, date: Date(),numberOfLikes:0,image: UIImage(),photoURL: "", documentID:"")
    }
    
    convenience init(dictionary: [String: Any]) {
        let title = dictionary["title"] as! String? ?? ""
        let body = dictionary["body"] as! String? ?? ""
        let hasImage = dictionary["hasImage"] as! Bool? ?? false
        let hashtag = dictionary["hashtag"] as! String? ?? ""
        let timeIntervalDate = dictionary["date"] as! TimeInterval? ?? TimeInterval()
        let date = Date(timeIntervalSince1970: timeIntervalDate)
        let postUserID = dictionary["postUserID"] as! String? ?? ""
        let numberOfLikes = dictionary["numberOfLikes"] as! Int? ?? 0
        let documentID = dictionary["documentID"] as! String? ?? ""
        let photoURL = dictionary["photoURL"] as! String? ?? ""
        
        self.init(title: title, body: body, hasImage: hasImage, hashtag: hashtag, postUserID: postUserID, date: date,numberOfLikes:numberOfLikes,image: UIImage(),photoURL:photoURL,documentID: documentID)
        
    }
    
    func saveData(completion:@escaping (Bool)->()){
        let db=Firestore.firestore()
        
        //create the dictionary
        let dataToSave: [String:Any]=self.dictionary
        
        if self.documentID==""{
            var ref:DocumentReference?=nil //create new id
            ref=db.collection("posts").addDocument(data: dataToSave){
                (error) in
                guard error==nil else{
                    print("ERROR: adding document \(error!.localizedDescription)")
                    return completion(false)
                }
                self.documentID=ref!.documentID
                print("Added document: \(self.documentID)")
                completion(true)
            }
            
        }else { //save to existing documentid
            let ref=db.collection("posts").document(self.documentID)
            ref.setData(dataToSave){(error) in
                guard error==nil else{
                    print("ERROR: updating document \(error!.localizedDescription)")
                    return completion(false)
                }
                print("Updated document: \(self.documentID)")
                completion(true)
                
            }
        }
        
    }
    
    func saveDataWithImage(completed:@escaping ()->()){
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
        
        let storageRef=storage.reference().child(self.documentID)
        
        let uploadTask=storageRef.putData(photoData, metadata: uploadMetaData) { (metadata, error) in
            if let error = error{
                print("ERROR:upload your ref \(uploadMetaData) failed. \(error.localizedDescription)")
            }
            
            
        }
        
        uploadTask.observe(.success) { (snapshot) in
            print("upload to Firebase storage successful")
            storageRef.downloadURL { (url, error) in
                guard error == nil else {
                    print("ERROR: couldn't create a download url \(error!.localizedDescription)")
                    return completed()
                }
                
                guard let url = url else{
                    print("ERROR: url is nil \(error!.localizedDescription)")
                    return
                }
                self.photoURL = "\(url)"
                
                let dataToSave = self.dictionary
                
                let ref = db.collection("posts").document(self.documentID)
                ref.setData(dataToSave) { (error) in
                    guard error == nil else {
                        print("ERROR: updating document \(error!.localizedDescription)")
                        return
                    }
                    
                    print("Updated document: \(self.documentID).")
                    completed()
                }
            }
            
        }
        
        uploadTask.observe(.failure) { (snapshot) in
            if let error = snapshot.error {
                print("ERROR:upload task for file \(self.documentID) failed, with error  \(error.localizedDescription)")
            }
            
            return
        }
    }
    
    func loadImage(completion: @escaping (Bool) -> ()) {
        
        
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
    
    
    
    
    func deleteData(completion:@escaping (Bool)->()){
        
        if self.hasImage{
            let storage=Storage.storage()
            
            let storageRef = storage.reference().child(documentID)
            
            storageRef.delete{ error in
                if let error = error {
                    print("ERROR: Couldn't delete photo \(error.localizedDescription)")
                    
                }else{
                    print("Photo successfully deleted",self.documentID)
                    
                }
                
            }
            
        }
        
        
        let db=Firestore.firestore()
        db.collection("posts").document(documentID).delete { (error) in
            if let error=error{
                print("ERROR:deleting post documentID \(self.documentID).ERROR:\(error.localizedDescription)")
                completion(false)
            }else{
                print("successfully deleted document \(self.documentID)")
                completion(true)
            }
        }
    }
    
    
    
    
    
}
