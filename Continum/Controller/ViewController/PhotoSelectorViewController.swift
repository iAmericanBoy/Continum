//
//  PhotoSelectorViewController.swift
//  Continum
//
//  Created by Dominic Lanzillotta on 2/27/19.
//  Copyright © 2019 Dominic Lanzillotta. All rights reserved.
//

import UIKit

protocol PhotoSelectorViewControllerDelegate: class {
    func photoSelectorViewControllerSelected(image: UIImage?)
}

class PhotoSelectorViewController: UIViewController {
    
    //MARK: - Outlets
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var selectPhotoButton: UIButton!
    
    //MARK: - Properties
    weak var delegate: PhotoSelectorViewControllerDelegate?

    //MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        selectPhotoButton.setTitle("SelectImage", for: .normal)
        photoImageView.image = nil
    }
    
    //MARK: - Actions
    @IBAction func selectPhotoButtonTapped(_ sender: UIButton) {
        selectImage()
    }
    
    //MARK: - Private Functions
    func selectImage() {
        let imagePickerAlertController = UIImagePickerController()
        imagePickerAlertController.allowsEditing = true
        imagePickerAlertController.delegate = self
        
        let imageAlert = UIAlertController(title: "Select Image", message: nil, preferredStyle: .actionSheet)
        
        let cameraAction = UIAlertAction(title: "Camera", style: .default) { (_) in
            imagePickerAlertController.sourceType = UIImagePickerController.SourceType.camera
            self.present(imagePickerAlertController,animated: true)
        }
        let photoAction = UIAlertAction(title: "Library", style: .default) { (_) in
            imagePickerAlertController.sourceType = UIImagePickerController.SourceType.photoLibrary
            self.present(imagePickerAlertController,animated: true)
        }
        imageAlert.addAction(cameraAction)
        imageAlert.addAction(photoAction)
        self.present(imageAlert, animated: true)
    }
}
extension PhotoSelectorViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        photoImageView.image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage
        delegate?.photoSelectorViewControllerSelected(image: photoImageView.image)
        self.dismiss(animated: true, completion: nil)
        self.selectPhotoButton.setTitle("", for: .normal)
    }
}
