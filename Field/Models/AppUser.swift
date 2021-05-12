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
    var intro: String?
    var pfpURL: String? //profile picture
    var coverURL: String? //cover picture
    var userid: String
    var documentID:String
    
    init(displayName:String,intro:String,pfpURL: String,coverURL: String,userid:String, documentID:String){
        self.displayName=displayName
        self.intro=intro
        self.pfpURL=pfpURL
        self.coverURL=coverURL
        self.userid=userid
        self.documentID = documentID
    }
    
    var dictionary: [String:Any]{
        return ["displayName":displayName,"intro":intro, "pfpURL":pfpURL, "coverURL":coverURL,"userid":userid]
    }

    
    convenience init(user:User){
        self.init(displayName:"",intro:"",pfpURL:"", coverURL:"",userid:"",documentID:user.uid)
    }
    
    convenience init(dictionary: [String:Any]){
        let displayName=dictionary["displayName"] as! String? ?? ""
        let intro=dictionary["intro"] as! String? ?? ""
        let pfpURL=dictionary["pfpURL"] as! String? ?? ""
        let coverURL=dictionary["coverURL"] as! String? ?? ""
        let userid=dictionary["userid"] as! String? ?? ""
        self.init(displayName:displayName,intro:intro,pfpURL:pfpURL, coverURL:coverURL,userid:userid, documentID:"")
        
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
        
        //grab user id
        guard let userid=Auth.auth().currentUser?.uid else{
            print("ERROR: Could not save data because we don't have a valid postingUserID")
            return completion(false)
        }
        self.userid=userid
        //create the dictionary
        let dataToSave: [String:Any]=self.dictionary
        
        if self.documentID==""{
            var ref: DocumentReference?=nil //create new id
            ref=db.collection("users").addDocument(data: dataToSave){
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
            let ref=db.collection("users").document(self.documentID)
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
    
    func loadData(id: String) {
        let db=Firestore.firestore()
        
        let ref=db.collection("users").document(id)

        ref.getDocument { (document, error) in
            if let error = error {
                print("ERROR: \(error.localizedDescription)")
            }
            
            if let document=document, document.exists{
                
                let appUser=AppUser(dictionary: document.data()!)
                appUser.documentID=document.documentID
            }else{
                print("document DNE")
            }
            
            //completion(true)
            
        }
    }
}


