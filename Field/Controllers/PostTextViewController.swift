//
//  PostTextViewController.swift
//  Field
//
//  Created by amyz on 5/13/21.
//

import UIKit
import Firebase

class PostTextViewController: UIViewController {
    
    @IBOutlet weak var bodyTextView: UITextView!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var hashtagTextField: UITextField!
    
    var post: Post!
    let userid=Auth.auth().currentUser?.uid ?? ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
        
        if post == nil{
            post=Post()
            
        }
        
    }
    
    func leaveViewController(){
        let isPresentingInAddMode=presentingViewController is UINavigationController
        if isPresentingInAddMode{
            let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)

            let nextViewController = storyBoard.instantiateViewController(withIdentifier: "home") as! HomeViewController
           
            self.navigationController?.pushViewController(nextViewController, animated: true)
            
        }else{
            navigationController?.popViewController(animated: true)
        }
        
    }
   
    @IBAction func postButtonPressed(_ sender: UIBarButtonItem) {
        post.title=titleTextField.text!
        post.body=bodyTextView.text!
        post.hashtag=hashtagTextField.text!
        post.postUserID=userid
        post.saveData { (success) in
           
            self.leaveViewController()
        }
        
        
    }
    
    @IBAction func cancelButtonPressed(_ sender: UIBarButtonItem) {
        leaveViewController()
    }
    
  

}
