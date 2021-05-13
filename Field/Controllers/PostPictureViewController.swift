//
//  PostPictureViewController.swift
//  Field
//
//  Created by amyz on 5/13/21.
//

import UIKit
import Firebase

class PostPictureViewController: UIViewController {
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var hashtagTextField: UITextField!
    @IBOutlet weak var bodyTextView: UITextView!
    
    var post: Post!
    let userid=Auth.auth().currentUser?.uid ?? ""
    var imagePickerController=UIImagePickerController()
    var postPhoto: PostPhoto!

    override func viewDidLoad() {
        super.viewDidLoad()
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
        
        if post == nil{
            post=Post()
        }
        if postPhoto==nil{
            postPhoto=PostPhoto()
        }
        imagePickerController.delegate=self

    }
    
    func leaveViewController(){
        let isPresentingInAddMode=presentingViewController is UINavigationController
        if isPresentingInAddMode{
            let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
            let nextViewController = storyBoard.instantiateViewController(withIdentifier: "home") as! HomePageViewController
            
            self.navigationController?.pushViewController(nextViewController, animated: true)
        }else{
            navigationController?.popViewController(animated: true)
        }
    }
    
    func showAlert(title:String, message: String){
        let alertController=UIAlertController(title: title,message: message,preferredStyle: .alert)
        let alertAction=UIAlertAction(title:"OK",style: .default, handler: nil)
        alertController.addAction(alertAction)
        present(alertController, animated: true, completion: nil)
    }
    @IBAction func photoOrCameraPressed(_ sender: UIButton) {
        let alertController=UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let photoLibraryAction=UIAlertAction(title: "Photo Library", style: .default) {(_) in
            self.accessPhotoLibrary()
        }
        let cameraAction=UIAlertAction(title:"Camera",style:.default) {(_) in
            self.accessCamera()
        }
        let cancelAction=UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(photoLibraryAction)
        alertController.addAction(cameraAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
    
    
    @IBAction func postButtonPressed(_ sender: UIBarButtonItem) {
        post.title=titleTextField.text!
        post.body=bodyTextView.text!
        post.hashtag=hashtagTextField.text!
        post.postUserID=userid
        post.hasImage=true
        print("sss",post.date,post.postUserID)
        
        postPhoto.image=imageView.image!
        
        post.saveData { (success) in
            self.postPhoto.saveData(post: self.post) { (success) in
                self.leaveViewController()
            }
        }
        
        
    }
    
    @IBAction func cancelButtonPressed(_ sender: UIBarButtonItem) {
        leaveViewController()
    }
    
}

extension PostPictureViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let editedImage=info[UIImagePickerController.InfoKey.editedImage] as? UIImage{
            imageView.image=editedImage
           
            
        }else if let originalImage=info[UIImagePickerController.InfoKey.originalImage] as? UIImage{
            imageView.image=originalImage
        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func accessPhotoLibrary(){
        imagePickerController.sourceType = .photoLibrary
        present(imagePickerController, animated: true, completion: nil)
    }
    func accessCamera(){
        if UIImagePickerController.isSourceTypeAvailable(.camera){
            imagePickerController.sourceType = .camera
        }else{
            showAlert(title: "Camera Not Avalible", message: "There's no camera availble on this device.")
        }
    }
}


