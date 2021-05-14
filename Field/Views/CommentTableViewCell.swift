//
//  CommentTableViewCell.swift
//  Field
//
//  Created by amyz on 5/14/21.
//

import UIKit

class CommentTableViewCell: UITableViewCell {
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var commentLabel: UILabel!
    
    var comment:Comment!{
        didSet{
            commentLabel.text=comment.text
            let id=comment.postUserID
            var appUser=AppUser(userid:id)
            appUser.loadData(id: id){
                self.name.text=appUser.displayName
            }
            
            
                
        }
    }
    
    
}
