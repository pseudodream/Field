//
//  EditViewController.swift
//  Field
//
//  Created by amyz on 5/9/21.
//

import UIKit
import Firebase
import SDWebImage

class EditViewController: UIViewController {
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var introTextField: UITextView!
    @IBOutlet weak var pfpImage: UIImageView!
    
    
    var appUser: AppUser!
    let userid=Auth.auth().currentUser?.uid ?? ""
    var imagePickerController=UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
      
        
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
        
        imagePickerController.delegate=self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        updateUserFromCloud()
    }
    
    func updateUserFromCloud(){
        appUser.loadData(id: userid){
            self.nameTextField.text=self.appUser.displayName
            self.introTextField.text=self.appUser.intro
            self.pfpImage.layer.cornerRadius=self.pfpImage.frame.size.width/2
            self.pfpImage.clipsToBounds=true
            guard let url = URL(string: self.appUser.photoURL) else {
                self.pfpImage.image=self.appUser.image
                return
            }
    
            self.pfpImage.sd_imageTransition = .fade
            self.pfpImage.sd_imageTransition?.duration = 0.5
            self.pfpImage.sd_setImage(with: url)
            
            
        }
    
    }
    
    
    @IBAction func saveButtonPressed(_ sender: UIBarButtonItem) {
        appUser.displayName=nameTextField.text!
        appUser.intro=introTextField.text!
        appUser.image=pfpImage.image ?? UIImage(named: "logo")! //this is the default profile image
        appUser.saveData { (success) in
            print("user info saved")
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


