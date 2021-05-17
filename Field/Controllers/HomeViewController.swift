//
//  ViewController.swift
//  Field
//
//  Created by amyz on 4/14/21.
//

import UIKit
import Firebase
import SDWebImage

class HomeViewController: UIViewController {
    var appUser: AppUser!
    var posts: Posts!
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    let userid=Auth.auth().currentUser?.uid ?? ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        posts=Posts()
        tableView.dataSource=self
        tableView.delegate=self
    
        if appUser==nil{
            appUser=AppUser(user: Auth.auth().currentUser!)
           
            appUser.saveIfNewUser { (success) in
                print("new user added")
            }
            appUser.loadData(id: userid){
                print("current user loaded")
            }
        }
       
       
        configureSegmentedControl()
     
        
    }

    
    
    override func viewWillAppear(_ animated: Bool) {
        
        segmentedControl.selectedSegmentIndex=0
        navigationController?.setToolbarHidden(true, animated: true)
        posts.loadData{
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowProfile"{
            let destination = segue.destination as! ProfileViewController
            destination.appUser=self.appUser
        }
        if segue.identifier=="ShowPost"{
            let destination=segue.destination as! DetailViewController
            let selectedIndexPath=tableView.indexPathForSelectedRow!
            destination.post=posts.postArray[selectedIndexPath.row]
          
            
        }
        
    }
    
    func configureSegmentedControl(){
        let FontColor=[NSAttributedString.Key.foregroundColor:UIColor(named:"textcolor") ?? UIColor.orange]
        segmentedControl.setTitleTextAttributes(FontColor, for:.selected)
        segmentedControl.setTitleTextAttributes(FontColor, for:.normal)
       
        
    }
    @IBAction func segmentedControlPressed(_ sender: UISegmentedControl) {
        sortBasedOnSegmentPressed()
    }
    
    func sortBasedOnSegmentPressed(){
        switch segmentedControl.selectedSegmentIndex{
        case 0: print("default")
        case 1:posts.postArray.sort(by: {$0.date > $1.date})
        case 2:posts.postArray.sort(by: {$0.numberOfLikes>$1.numberOfLikes})
    
        default:
            print("check segment control for error")
        }
        DispatchQueue.main.async {
            self.tableView.reloadData()
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

extension HomeViewController: UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.postArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! PostTableViewCell
        
        cell.post=posts.postArray[indexPath.row]
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 395
    }
    
    
    
}
