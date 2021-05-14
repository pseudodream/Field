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
    var documentID:String
    
    init(displayName:String,intro:String, documentID:String){
        self.displayName=displayName
        self.intro=intro
        self.documentID = documentID
    }
    
    var dictionary: [String:Any]{
        return ["displayName":displayName,"intro":intro]
    }

    
    convenience init(user:User){
        self.init(displayName:"",intro:"",documentID:user.uid)
    }
    convenience init(userid:String){
        self.init(displayName:"",intro:"", documentID:userid)
    }
    
    convenience init(dictionary: [String:Any]){
        let displayName=dictionary["displayName"] as! String? ?? ""
        let intro=dictionary["intro"] as! String? ?? ""
        
        self.init(displayName:displayName,intro:intro, documentID:"")
        
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
    
}


