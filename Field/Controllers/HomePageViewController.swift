//
//  ViewController.swift
//  Field
//
//  Created by amyz on 4/14/21.
//

import UIKit
import Firebase

class HomePageViewController: UIViewController {
    var appUser: AppUser!
    
    let userid=Auth.auth().currentUser?.uid ?? ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(userid)
        
        if appUser==nil{
            appUser=AppUser(user: Auth.auth().currentUser!)
            appUser.saveIfNewUser { (success) in
            }
        appUser.loadData(id: userid)
            
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        appUser.loadData(id: userid)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowProfile"{
            let destination = segue.destination as! ProfileViewController
            destination.appUser=self.appUser
        }
    }
    
    
    @IBAction func showPopUp(_ sender: UIBarButtonItem) {
        let popOverViewController=UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "PopUpID") as! AddPopUpViewController
        self.addChild(popOverViewController)
        popOverViewController.view.frame=self.view.frame
        self.view.addSubview(popOverViewController.view)
        popOverViewController.didMove(toParent: self)
        
    }
    
} 
