//
//  Comment.swift
//  Field
//
//  Created by amyz on 5/13/21.
//

import Foundation
import Firebase

class Comment {
    var text: String
    var postUserID: String
    var documentID: String
    
    var dictionary: [String: Any] {
        return ["text": text, "postUserID": postUserID]
    }
    
    init(text: String,postUserID: String,documentID: String){
        self.text=text
        self.postUserID=postUserID
        self.documentID=documentID
    }
    
    convenience init(){
        let postUserID = Auth.auth().currentUser?.uid ?? ""
        self.init(text: "", postUserID:postUserID, documentID:"")
    }
    
    convenience init(dictionary: [String: Any]) {
        let text = dictionary["text"] as! String? ?? ""
        let postUserID = dictionary["postUserID"] as! String? ?? ""
        let documentID = dictionary["documentID"] as! String? ?? ""
        self.init(text: text, postUserID:postUserID, documentID: documentID)
    }
    
    func saveData(post:Post!, completion:@escaping (Bool)->()){
        let db=Firestore.firestore()
        
        //create the dictionary
        let dataToSave: [String:Any]=self.dictionary
        
        
        if self.documentID==""{
            var ref:DocumentReference?=nil //create new id
            ref=db.collection("posts").document(post.documentID).collection("commentss").addDocument(data: dataToSave){
                (error) in
                guard error==nil else{
                    print("ERROR: adding document \(error!.localizedDescription)")
                    return completion(false)
                }
                self.documentID=ref!.documentID
                print("Added document: \(self.documentID) to post \(post.documentID )")
                
            }
            
            
        }else { //save to existing documentid
            let ref=db.collection("posts").document(post.documentID).collection("commentss").document(self.documentID)
            ref.setData(dataToSave){(error) in
                guard error==nil else{
                    print("ERROR: updating document \(error!.localizedDescription)")
                    return completion(false)
                }
                print("Updated document: \(self.documentID)to post \(post.documentID )")
                
            }
        }
    }
    
    func deleteData(post: Post, completion:@escaping (Bool)->()){
        let db=Firestore.firestore()
        db.collection("posts").document(post.documentID).collection("commentss").document(documentID).delete { (error) in
            if let error=error{
                print("ERROR:deleting review documentID \(self.documentID).ERROR:\(error.localizedDescription)")
                completion(false)
            }else{
                print("successfully deleted document \(self.documentID)")
                
            }
        }
    }
    
}
