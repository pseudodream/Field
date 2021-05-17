//
//  PostTableViewCell.swift
//  Field
//
//  Created by amyz on 5/13/21.
//

import UIKit
import Firebase
import SDWebImage
private let dateFormatter: DateFormatter = {
    let dateFormatter=DateFormatter()
    dateFormatter.dateStyle = .medium
    dateFormatter.timeStyle = .none
    return dateFormatter
}()

class PostTableViewCell: UITableViewCell {
    
    @IBOutlet weak var pfpImage: UIImageView!
    @IBOutlet weak var likeCountLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var textPosted: UITextView!
    @IBOutlet weak var imagePosted: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var hashtagLabel: UILabel!
    
   
    var post:Post! {
        willSet{
            pfpImage.image=nil
            imagePosted.image=nil
            dateLabel.text=""
            userNameLabel.text=""
            textPosted.text=""
            titleLabel.text=""
            hashtagLabel.text=""
            likeCountLabel.text=""
        }
    
        didSet{
            hashtagLabel.text=post.hashtag
            dateLabel.text="Posted on: \(dateFormatter.string(from: post.date))"
            likeCountLabel.text="\(post.numberOfLikes)"
            let id=post.postUserID
            var appUser=AppUser(userid:id)
            appUser.loadData(id: id){
                self.userNameLabel.text=appUser.displayName
            }
            self.pfpImage.layer.cornerRadius=self.pfpImage.frame.size.width/2
            self.pfpImage.clipsToBounds=true
            
            appUser.loadImage { (success) in
                guard let url = URL(string: appUser.photoURL) else {
                    self.pfpImage.image = appUser.image
                    return
                }
                self.pfpImage.sd_imageTransition = .fade
                self.pfpImage.sd_imageTransition?.duration = 0.5
                self.pfpImage.sd_setImage(with: url)
                
            }
            
            
            titleLabel.text=post.title
            if post.hasImage == true{
                textPosted.isHidden=true
                post.loadImage { (success) in
                    guard let url = URL(string: self.post.photoURL) else {
                        self.imagePosted.image = self.post.image
                        return
                    }
                    self.imagePosted.sd_imageTransition = .fade
                    self.imagePosted.sd_imageTransition?.duration = 0.5
                    self.imagePosted.sd_setImage(with: url)
                    
                }
                
                
            }else{
                imagePosted.isHidden=true
                textPosted.text=post.body
            }
           
        }
    }
    
  
    
    
}
