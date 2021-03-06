//
// Created by dc on 2019-05-11.
// Copyright (c) 2019 Dont Eat Alone. All rights reserved.
//

import UIKit

class EditProfileViewController: UIViewController, UITextViewDelegate, ProfilePictureDownloadDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, ProfilePictureUploadDelegate, UITextFieldDelegate {

    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var userName: UITextField!
    @IBOutlet weak var year: UISegmentedControl!
    @IBOutlet weak var major: UITextField!
    @IBOutlet weak var bio: UITextView!
    @IBOutlet weak var bioChar: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var stackView: UIStackView!
    var imagePickerController: UIImagePickerController?
    var activeField: UIView?

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        profilePic.layer.cornerRadius = profilePic.frame.size.width / 2
        profilePic.clipsToBounds = true
        profilePic.layer.shadowColor = UIColor.lightGray.cgColor
        profilePic.layer.shadowOffset = CGSize(width: 0, height: 1)
        profilePic.layer.shadowOpacity = 1
        profilePic.layer.shadowRadius = 1.0
        profilePic.layer.masksToBounds = true
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(picTapped(tapGestureRecognizer:)))
        profilePic.isUserInteractionEnabled = true
        profilePic.addGestureRecognizer(tapGestureRecognizer)

        userName.text = UserDefaultsManager.shared.getFirstName()
        year.selectedSegmentIndex = UserDefaultsManager.shared.getYear() - 1
        major.text = UserDefaultsManager.shared.getMajor()
        bio.text = UserDefaultsManager.shared.getSelfBio()
        bio.delegate = self
        bioChar.text = "\(bio.text.count)"

        self.userName.delegate = self
        self.major.delegate = self

        registerForKeyboardNotifications()
        
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing))
        stackView.addGestureRecognizer(tap)
        
        ProfilePictureAPI().download(pictureForUserID: UserManager.shared.getUID(), delegate: self)
    }

    func profilePicture(didDownloadimage image: UIImage, forUserWithID _: Int) {
        profilePic.image = image
    }

    func profilePicture(failedWithError error: String?) {
        print("Failed to download profile picture: \(error ?? "")")
    }

    override func viewWillDisappear(_ animated: Bool) {
        deregisterFromKeyboardNotifications()
        if self.navigationController?.viewControllers.index(of: self) == nil {
            if let userNameText = userName.text,
               let majorText = major.text,
               let bioText = bio.text {
                print(year.selectedSegmentIndex)
                UserManager.shared.signupUpdate(
                        email: UserDefaultsManager.shared.getUserEmail(),
                        first_name: userNameText,
                        last_name: "",
                        major: majorText,
                        minor: "",
                        year: year.selectedSegmentIndex + 1,
                        self_bio: bioText
                )
            }
        }
        super.viewWillDisappear(animated)
    }

    func textView(_ BioTextBox: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newText = (BioTextBox.text as NSString).replacingCharacters(in: range, with: text)
        let numberOfChars = newText.count
        self.bioChar.text = "\(numberOfChars)"
        return numberOfChars < 250    // 250 character limit for Bio
    }


    @objc func picTapped(tapGestureRecognizer: UITapGestureRecognizer) {
        // Allows user to choose between photo library and camera
        let alertController = UIAlertController(title: nil, message: "Where do you want to get your picture from?", preferredStyle: .actionSheet)

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)

        let photoLibraryAction = UIAlertAction(title: "Photo from Library", style: .default) { (action) in
            self.showImagePickerController(sourceType: .photoLibrary)
        }

        alertController.addAction(photoLibraryAction)

        // Only show camera option if rear camera is available
        if (UIImagePickerController.isCameraDeviceAvailable(.rear)) {
            let cameraAction = UIAlertAction(title: "Photo from Camera", style: .default) { (action) in
                self.showImagePickerController(sourceType: .camera)
            }
            alertController.addAction(cameraAction)
        }
        present(alertController, animated: true, completion: nil)
    }


    func showImagePickerController(sourceType: UIImagePickerControllerSourceType) {
        imagePickerController = UIImagePickerController()
        imagePickerController!.sourceType = sourceType
        imagePickerController!.delegate = self
        present(imagePickerController!, animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String: Any]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            self.profilePic.image = pickedImage

            ProfilePictureAPI().upload(profilePicture: pickedImage, delegate: self)
        }

        dismiss(animated: true, completion: nil)
    }

    func profilePicture(uploadCompleted: Bool, failedWithError error: String?) {
        if (uploadCompleted) {
            // do nothing weeee
        } else {
            print("Failed to upload profile picture: " + (error ?? ""))
            let alert = UIAlertController(title: "Upload Failed", message: "Your photo could not be uploaded at this time. Please try again later.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
                self.profilePic.image = UIImage(named: "ProfilePic")
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    
    func registerForKeyboardNotifications()
    {
        //Adding notifies on keyboard appearing
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWasShown), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillBeHidden), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }


    func deregisterFromKeyboardNotifications()
    {
        //Removing notifies on keyboard appearing
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }

    @objc func keyboardWasShown(notification: NSNotification){
        //Need to calculate keyboard exact size due to Apple suggestions
        self.scrollView.isScrollEnabled = true
        let info = notification.userInfo!
        let keyboardSize = (info[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.size
        let contentInsets : UIEdgeInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: keyboardSize!.height, right: 0.0)

        self.scrollView.contentInset = contentInsets
        self.scrollView.scrollIndicatorInsets = contentInsets

        var aRect : CGRect = self.view.frame
        aRect.size.height -= keyboardSize!.height
        if let activeField = self.activeField {
            if (!aRect.contains(activeField.frame.origin)){
                self.scrollView.scrollRectToVisible(activeField.frame, animated: true)
            }
        }
    }

    @objc func keyboardWillBeHidden(notification: NSNotification){
        //Once keyboard disappears, restore original positions
        let info = notification.userInfo!
        let keyboardSize = (info[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.size
        let contentInsets : UIEdgeInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: -keyboardSize!.height, right: 0.0)
        self.scrollView.contentInset = contentInsets
        self.scrollView.scrollIndicatorInsets = contentInsets
        self.view.endEditing(true)
        self.scrollView.isScrollEnabled = false
    }

    func textFieldDidBeginEditing(_ textField: UITextField){
        activeField = textField
    }

    func textFieldDidEndEditing(_ textField: UITextField){
        activeField = nil
    }
    
    func textViewDidBeginEditing(_ textView: UITextView){
        activeField = textView
    }

    func textViewDidEndEditing(_ textView: UITextView){
        activeField = nil
    }
}

