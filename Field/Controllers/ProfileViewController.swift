//
//  ProfileViewController.swift
//  Field
//
//  Created by amyz on 5/9/21.
//

import UIKit
import Firebase

class ProfileViewController: UIViewController {
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var coverImage: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var intro: UILabel!
    
    var appUser: AppUser!
    let userid=Auth.auth().currentUser?.uid ?? ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateUserFromCloud()
        print("nn",appUser.displayName)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        updateUserFromCloud()
    }
    
    func updateUserFromCloud(){
        appUser.loadData(id: userid){
            
        }
        print(appUser.displayName)
        userName.text=appUser.displayName
        intro.text=appUser.intro
        
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier=="SaveProfile"{
            let destination = segue.destination as! EditViewController
            destination.appUser=appUser
        }
    }
    

  

}
