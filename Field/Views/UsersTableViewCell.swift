//
//  UsersTableViewCell.swift
//  Field
//
//  Created by amyz on 5/17/21.
//

import UIKit

class UsersTableViewCell: UITableViewCell {

    @IBOutlet weak var profilePic: UIImageView!
    
    @IBOutlet weak var introLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    
    var appUser:AppUser!{
        didSet{
            appUser.loadImage { (success) in
                self.profilePic.image=self.appUser.image
                self.profilePic.layer.cornerRadius=self.profilePic.frame.size.width/2
                self.profilePic.clipsToBounds=true
            }
            
            
            introLabel.text=appUser.intro
            nameLabel.text=appUser.displayName
        }
    }
    
}
