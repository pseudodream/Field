//
//  EditViewController.swift
//  Field
//
//  Created by amyz on 5/9/21.
//

import UIKit
import Firebase

class EditViewController: UIViewController {
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var introTextField: UITextView!
    @IBOutlet weak var pfpImage: UIImageView!
    @IBOutlet weak var coverImage: UIImageView!
    
    var appUser: AppUser!
    var userPhoto: UserPhoto!
    let userid=Auth.auth().currentUser?.uid ?? ""
    var imagePickerController=UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        userPhoto=UserPhoto()
        
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
        
        imagePickerController.delegate=self
        updateUserFromCloud()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        updateUserFromCloud()
    }
    
    func updateUserFromCloud(){
        appUser.loadData(id: userid){
           
        }
        nameTextField.text=appUser.displayName
        introTextField.text=appUser.intro
        let db=Firestore.firestore()
        var userPhoto=UserPhoto()
        db.collection("users").document(appUser.documentID).collection("profilePicture").getDocuments { (querySnapshot, error) in
            guard error == nil else {
                print("ERROR: adding the snapshot listener \(error!.localizedDescription)")
               return
            }
            for document in querySnapshot!.documents{
                userPhoto.documentID=document.documentID
                print(document.documentID)
                userPhoto.loadImage(appUser:self.appUser){(success) in
                    self.pfpImage.image=userPhoto.image
                    print(userPhoto.photoURL)
                    guard let url = URL(string: userPhoto.photoURL) else {
                        return
                    }
                    print("ddd\(url)")
                    self.pfpImage.sd_imageTransition = .fade
                    self.pfpImage.sd_imageTransition?.duration = 0.5
                    self.pfpImage.sd_setImage(with: url)
                }
            }
        }
       
        
    }
    
    func updateUser(){
        appUser.displayName=nameTextField.text!
        appUser.intro=introTextField.text!
        appUser.saveData { (success) in
            print("user info saved")
        }
        userPhoto.image=pfpImage.image ?? UIImage()
        userPhoto.saveData(appUser: appUser) { (success) in
            print("imageSaved")
        }
        
    }
    
    
    @IBAction func saveButtonPressed(_ sender: UIBarButtonItem) {
        updateUser()
        
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

    
}


extension EditViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let editedImage=info[UIImagePickerController.InfoKey.editedImage] as? UIImage{
            pfpImage.image=editedImage
           
            
        }else if let originalImage=info[UIImagePickerController.InfoKey.originalImage] as? UIImage{
            pfpImage.image=originalImage
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


