//
//  UsersListViewController.swift
//  Field
//
//  Created by amyz on 5/17/21.
//

import UIKit

class UsersListViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    var appUsers: AppUsers!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate=self
        tableView.dataSource=self
        appUsers=AppUsers()
        appUsers.loadData {
            self.tableView.reloadData()
        }

    }

}

extension UsersListViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return appUsers.userArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! UsersTableViewCell
        cell.appUser=appUsers.userArray[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
}


