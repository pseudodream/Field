//
//  PostTextViewController.swift
//  Field
//
//  Created by amyz on 5/13/21.
//

import UIKit

class PostTextViewController: UIViewController {
    
    @IBOutlet weak var bodyTextView: UITextView!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var hashtagTextView: UITextField!
    
    var post: Post!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

   
    @IBAction func postButtonPressed(_ sender: UIBarButtonItem) {
    }
    
    @IBAction func cancelButtonPressed(_ sender: UIBarButtonItem) {
    }
    
  
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
