//
//  CommentViewController.swift
//  Field
//
//  Created by amyz on 5/13/21.
//

import UIKit

class CommentViewController: UIViewController {

    @IBOutlet weak var commentTextView: UITextView!
    var comment:Comment!
    var post: Post!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor=UIColor.black.withAlphaComponent(0)
        comment=Comment()

    }
    
    @IBAction func cancelPressed(_ sender: UIButton){
        self.view.removeFromSuperview()
    }
    
    @IBAction func addButtonPressed(_ sender: UIButton) {
        comment.text=commentTextView.text!
        comment.saveData(post: post) { (success) in
           
            self.view.removeFromSuperview()
        }
        
    }
}
