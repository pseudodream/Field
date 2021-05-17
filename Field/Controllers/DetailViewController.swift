//
//  DetailViewController.swift
//  Field
//
//  Created by amyz on 5/13/21.
//

import UIKit
import Firebase
import SDWebImage

private let dateFormatter: DateFormatter = {
    let dateFormatter=DateFormatter()
    dateFormatter.dateStyle = .medium
    dateFormatter.timeStyle = .none
    return dateFormatter
}()

class DetailViewController: UIViewController {
    
    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var imageDescriptionTextView: UITextView!
    @IBOutlet weak var hashtagLabel: UILabel!
    @IBOutlet weak var likesCountLabel: UILabel!
    
    
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var commentCountLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    var post: Post!
    var comments: Comments!
    var appUser:AppUser!
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate=self
        tableView.dataSource=self
        
        userName.text=""
        dateLabel.text=""
        
        comments=Comments()
        
        updateUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setToolbarHidden(true, animated: true)
        comments.loadData(post: post) {
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.updateUI()
            }
        }
        
        
    }
    
    func updateUI(){
        if post.postUserID != Auth.auth().currentUser?.uid{
            deleteButton.isHidden=true
        }
        
        
        var postUser=AppUser(userid: post.postUserID )
        postUser.loadData(id: post.postUserID) {
            self.userName.text=postUser.displayName
        }
        
        postUser.loadImage { (success) in
            
            self.profilePic.layer.cornerRadius=self.profilePic.frame.size.width/2
            self.profilePic.clipsToBounds=true
            
            guard let url = URL(string: postUser.photoURL) else {
                self.profilePic.image=postUser.image
                return
            }
            self.profilePic.sd_imageTransition = .fade
            self.profilePic.sd_imageTransition?.duration = 0.5
            self.profilePic.sd_setImage(with: url)
        }
        
        
        dateLabel.text="Posted on: \(dateFormatter.string(from: post.date))"
        likesCountLabel.text="\(post.numberOfLikes)"
        commentCountLabel.text="Comments (\(comments.commentArray.count))"
        titleLabel.text=post.title
        hashtagLabel.text=post.hashtag
        if post.hasImage{
            imageDescriptionTextView.text=post.body
            textView.isHidden=true
            guard let url = URL(string: postUser.photoURL) else {
                self.imageView.image=self.post.image
                
                return
            }
            self.imageView.sd_imageTransition = .fade
            self.imageView.sd_imageTransition?.duration = 0.5
            self.imageView.sd_setImage(with: url)
            
        }else{
            imageView.isHidden=true
            imageDescriptionTextView.isHidden=true
            textView.text=post.body
            
        }
        
    }
    @IBAction func likePressed(_ sender: Any) {
        post.numberOfLikes+=1
        post.saveData{(success) in
            self.updateUI()
        }
    }
    
    
    @IBAction func CommentPressed(_ sender: UIButton) {
        
        let popOverViewController=UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "comment") as! CommentViewController
        popOverViewController.post=self.post
        self.addChild(popOverViewController)
        popOverViewController.view.frame=self.view.frame
        self.view.addSubview(popOverViewController.view)
        popOverViewController.didMove(toParent: self)
    }
    
    
    
    @IBAction func deleteButton(_ sender: UIButton) {
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "home") as! HomeViewController
        post.deleteData{(success) in
            self.navigationController?.pushViewController(nextViewController, animated: true)
        }
        
    }
}

extension DetailViewController: UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.commentArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell=tableView.dequeueReusableCell(withIdentifier: "CommentCell",for: indexPath) as! CommentTableViewCell
        cell.comment=comments.commentArray[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    
}

