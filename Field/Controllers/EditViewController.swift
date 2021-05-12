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
    let userid=Auth.auth().currentUser?.uid ?? ""
    var imagePickerController=UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        appUser.loadData(id: userid)
        nameTextField.text=appUser.displayName
        introTextField.text=appUser.intro!
        
    }
    
    func updateUser(){
        appUser.displayName=nameTextField.text!
        appUser.intro=introTextField.text!
        appUser.saveData { (success) in
            print("user info saved")
        }
    }
    
    
    @IBAction func saveButtonPressed(_ sender: UIBarButtonItem) {
        updateUser()
        
    }
    
   
//    override func unwind(for unwindSegue: UIStoryboardSegue, towards subsequentVC: UIViewController) {
//        let source = unwindSegue.source as! ProfileViewController
//        source.appUser=self.appUser
//    }
//
    
    func cameraOrLibraryAlert(){
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        let photoLibraryAction = UIAlertAction(title: "Photo Library", style: .default) { (_) in
            self.accessPhotoLibrary()
        }
        let cameraAction = UIAlertAction(title: "Camera", style: .default) { (_) in
            self.accessCamera()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)

        alertController.addAction(photoLibraryAction)
        alertController.addAction(cameraAction)
        alertController.addAction(cancelAction)

        present(alertController, animated: true, completion: nil)
    }
    
//    func takePhoto{
//        if user.documentID==""{
//            saveCancelAlert(title: "This Venue Has Not Been Saved", message: "You must save this venue before you can review it.", segueIdentifier: "AddPhoto")
//        }else{
//            cameraOrLibraryAlert()
//        }
//    }
//
//
    
    @IBAction func pfpCamera(_ sender: UIButton) {
        cameraOrLibraryAlert()
        
    }
    
}


extension EditViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
         

        if let editedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
             pfpImage.image = editedImage
        } else if let originalImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
             pfpImage.image = originalImage
        }
        dismiss(animated: true) {
            self.performSegue(withIdentifier: "AddPhoto", sender: nil)
        }
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }

    func accessPhotoLibrary() {
        imagePickerController.sourceType = .photoLibrary
        present(imagePickerController, animated: true, completion: nil)
    }

    func accessCamera() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            imagePickerController.sourceType = .camera
            present(imagePickerController, animated: true, completion: nil)
        } else {
            self.oneButtonAlert(title: "Camera Not Available", message: "There is no camera available on this device.")
        }
    }
}

