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
    
    var dictionary: [String: Any] {
        let timeIntervalDate = date.timeIntervalSince1970
        return ["title": title, "body": body, "hasImage": hasImage, "hashtag": hashtag, "postUserID": postUserID, "date": timeIntervalDate,"numberOfLikes":numberOfLikes]
    }
  
    init(title: String, body: String, hasImage: Bool,hashtag: String, postUserID: String, date: Date,numberOfLikes:Int, documentID: String) {
           self.title = title
           self.body = body
           self.hasImage = hasImage
           self.postUserID = postUserID
           self.hashtag = hashtag
           self.date = date
           self.numberOfLikes=numberOfLikes
           self.documentID = documentID
        
    }
    
    convenience init() {
            let postUserID = Auth.auth().currentUser?.uid ?? ""
            self.init(title: "", body: "", hasImage: false,hashtag: "", postUserID: postUserID, date: Date(),numberOfLikes:0, documentID:"")
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
           
        self.init(title: title, body: body, hasImage: hasImage, hashtag: hashtag, postUserID: postUserID, date: date,numberOfLikes:numberOfLikes,documentID: documentID)
        
    }
    
    func saveData(completion:@escaping (Bool)->()){
        let db=Firestore.firestore()
        
        //create the dictionary
        let dataToSave: [String:Any]=self.dictionary
        print("dt",dataToSave)
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
    
       
    
    
    
    func deleteData(completion:@escaping (Bool)->()){
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
