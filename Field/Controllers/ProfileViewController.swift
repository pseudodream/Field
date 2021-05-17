//
//  ProfileViewController.swift
//  Field
//
//  Created by amyz on 5/9/21.
//

import UIKit
import Firebase
import SDWebImage

class ProfileViewController: UIViewController {
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var intro: UILabel!
    
    var appUser: AppUser!
    var posts:Posts!
    let userid=Auth.auth().currentUser?.uid ?? ""
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource=self
        tableView.delegate=self
        
        updateUserFromCloud()
        
        posts=Posts()
        posts.loadUserData(appUser: appUser) {
            self.tableView.reloadData()
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        updateUserFromCloud()
        tableView.reloadData()
    }
    
    func updateUserFromCloud(){
        appUser.loadData(id: userid){
            self.userName.text = self.appUser.displayName == "" ? "UserName" : self.appUser.displayName
            self.intro.text = self.appUser.intro
            
        }
        appUser.loadImage { (success) in
            guard let url = URL(string: self.appUser.photoURL) else {
                self.profileImage.image=self.appUser.image
                return
            }
            
            self.profileImage.layer.cornerRadius=self.profileImage.frame.size.width/2
            self.profileImage.clipsToBounds=true
            self.profileImage.sd_imageTransition = .fade
            self.profileImage.sd_imageTransition?.duration = 0.5
            self.profileImage.sd_setImage(with: url)
            
        }
        
        if profileImage.image==UIImage(){
            profileImage.image=UIImage(named: "logo")
        }
        
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier=="SaveProfile"{
            let destination = segue.destination as! EditViewController
            destination.appUser=appUser
        }
        if segue.identifier=="ShowFromProfile"{
            let destination=segue.destination as! DetailViewController
            let selectedIndexPath=tableView.indexPathForSelectedRow!
            destination.post=posts.postArray[selectedIndexPath.row]
        }
    }
}

extension ProfileViewController: UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.postArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! ProfilePostTableViewCell
        
        cell.post=posts.postArray[indexPath.row]
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 395
    }
    
    
    
}
