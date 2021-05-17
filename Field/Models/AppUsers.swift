//
//  AppUsers.swift
//  Field
//
//  Created by amyz on 5/9/21.
//
import Foundation
import Firebase

class AppUsers{
    var userArray: [AppUser]=[]
    var db: Firestore!
    
    init(){
        db=Firestore.firestore()
    }
    
    func loadFollwingData(list:[String],completed: @escaping()->()){
        db.collection("users").addSnapshotListener { (querySnapshot, error) in
            guard error == nil else{
                print("ERROR: adding the snapshot listener \(error!.localizedDescription)")
                return completed()
            }
            self.userArray=[]
            for document in querySnapshot!.documents{
                for i in list{
                    if document.documentID==i{
                        let appUser=AppUser(dictionary: document.data())
                        appUser.documentID=document.documentID
                        self.userArray.append(appUser)
                    }
                }
              
            }
            completed()
        }
    }
    
    
    func loadData(completed: @escaping()->()){
        db.collection("users").addSnapshotListener { (querySnapshot, error) in
            guard error == nil else{
                print("ERROR: adding the snapshot listener \(error!.localizedDescription)")
                return completed()
            }
            self.userArray=[]
            for document in querySnapshot!.documents{
                let appUser=AppUser(dictionary: document.data())
                appUser.documentID=document.documentID
                self.userArray.append(appUser)
                
            }
            completed()
        }
    }
}
