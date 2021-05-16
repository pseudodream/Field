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
        var d=post.getImageID()
        print("dddd",d )
        
        var postUser=AppUser(userid: post.postUserID )
        postUser.loadData(id: post.postUserID) {
            self.userName.text=postUser.displayName
            
        }
        
        let db=Firestore.firestore()
        var userPhoto=UserPhoto()
        db.collection("users").document(postUser.documentID).collection("profilePicture").getDocuments { (querySnapshot, error) in
            guard error == nil else {
                print("ERROR: adding the snapshot listener \(error!.localizedDescription)")
               return
            }
            for document in querySnapshot!.documents{
                userPhoto.documentID=document.documentID
                userPhoto.loadImage(appUser:postUser){(success) in
                  
                    guard let url = URL(string: userPhoto.photoURL) else {
                        self.profilePic.image = userPhoto.image
                        return
                    }
                    self.profilePic.sd_imageTransition = .fade
                    self.profilePic.sd_imageTransition?.duration = 0.5
                    self.profilePic.sd_setImage(with: url)
                    print("uu",url)
                    self.profilePic.layer.cornerRadius=self.profilePic.frame.size.width/2
                    self.profilePic.clipsToBounds=true
                   // self.profilePic.image=userPhoto.image
                    
                }
            }
        }
       
        dateLabel.text="Posted on: \(dateFormatter.string(from: post.date))"
        likesCountLabel.text="\(post.numberOfLikes)"
        commentCountLabel.text="Comments (\(comments.commentArray.count))"
        titleLabel.text=post.title
        hashtagLabel.text=post.hashtag
        if post.hasImage{
            imageDescriptionTextView.text=post.body
            textView.isHidden=true
            var postPhoto=PostPhoto()
            let db=Firestore.firestore()
            db.collection("posts").document(post.documentID).collection("photos").getDocuments { (querySnapshot, error) in
                guard error == nil else {
                    print("ERROR: adding the snapshot listener \(error!.localizedDescription)")
                   return
                }
                for document in querySnapshot!.documents{
                    postPhoto.documentID=document.documentID//currently only support add one photo per post
                    postPhoto.loadImage(post: self.post){(success) in
                        self.imageView.image=postPhoto.image
                    }
                }
            }
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
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "home") as! HomePageViewController
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
