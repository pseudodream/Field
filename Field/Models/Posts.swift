//
//  Posts.swift
//  Field
//
//  Created by amyz on 5/13/21.
//

import Foundation
import Firebase



class Posts{
    var postArray: [Post]=[]
    var db: Firestore!
    
    init(){
        db=Firestore.firestore()
    }
    
    func loadData(completed: @escaping()->()){
        db.collection("posts").addSnapshotListener { (querySnapshot, error) in
            guard error == nil else{
                print("ERROR: adding the snapshot listener \(error!.localizedDescription)")
                return completed()
            }
            self.postArray=[]
            for document in querySnapshot!.documents{
                let post=Post(dictionary: document.data())
                post.documentID=document.documentID
                self.postArray.append(post)
                
            }
            completed()
        }
    }
    
    func loadUserData(appUser:AppUser,completed: @escaping()->()){
        db.collection("posts").addSnapshotListener { (querySnapshot, error) in
            guard error == nil else{
                print("ERROR: adding the snapshot listener \(error!.localizedDescription)")
                return completed()
            }
            self.postArray=[]
            for document in querySnapshot!.documents{
                let post=Post(dictionary: document.data())
                if post.postUserID==appUser.documentID{
                    post.documentID=document.documentID
                    self.postArray.append(post)
                }
                
            }
            completed()
        }
    }
}
