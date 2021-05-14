//
//  ProfilePostTableViewCell.swift
//  Field
//
//  Created by amyz on 5/14/21.
//

import UIKit
import Firebase
private let dateFormatter: DateFormatter = {
    let dateFormatter=DateFormatter()
    dateFormatter.dateStyle = .medium
    dateFormatter.timeStyle = .none
    return dateFormatter
}()

class ProfilePostTableViewCell: UITableViewCell {
    @IBOutlet weak var pfpImage: UIImageView!
    @IBOutlet weak var likeCountLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var textPosted: UITextView!
    @IBOutlet weak var imagePosted: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var hashtagLabel: UILabel!
    
    var post: Post!{
        didSet{
            likeCountLabel.text="\(post.numberOfLikes)"
            let id=post.postUserID
            var appUser=AppUser(userid:id)
            appUser.loadData(id: id){
                self.userNameLabel.text=appUser.displayName
            }
            
            let db=Firestore.firestore()
            var userPhoto=UserPhoto()
            db.collection("users").document(appUser.documentID).collection("profilePicture").getDocuments { (querySnapshot, error) in
                guard error == nil else {
                    print("ERROR: adding the snapshot listener \(error!.localizedDescription)")
                   return
                }
                for document in querySnapshot!.documents{
                    userPhoto.documentID=document.documentID
                    userPhoto.loadImage(appUser:appUser){(success) in
                        self.pfpImage.layer.cornerRadius=self.pfpImage.frame.size.width/2
                        self.pfpImage.clipsToBounds=true
                        self.pfpImage.image=userPhoto.image
                        
                    }
                }
            }
            
            titleLabel.text=post.title
            if post.hasImage == true{
                textPosted.isHidden=true
                var postPhoto=PostPhoto()
                db.collection("posts").document(post.documentID).collection("photos").getDocuments { (querySnapshot, error) in
                    guard error == nil else {
                        print("ERROR: adding the snapshot listener \(error!.localizedDescription)")
                       return
                    }
                    for document in querySnapshot!.documents{
                        postPhoto.documentID=document.documentID//currently only support add one photo per post
                        postPhoto.loadImage(post: self.post){(success) in
                            
                            self.imagePosted.image=postPhoto.image
                            
                        }
                    }
                }
                
            }else{
                imagePosted.isHidden=true
                textPosted.text=post.body
            }
            
            hashtagLabel.text=post.hashtag
            dateLabel.text="Posted on: \(dateFormatter.string(from: post.date))"
        }
    }
   
}
