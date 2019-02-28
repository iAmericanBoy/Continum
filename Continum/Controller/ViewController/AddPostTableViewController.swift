//
//  AddPostTableViewController.swift
//  Continum
//
//  Created by Dominic Lanzillotta on 2/26/19.
//  Copyright © 2019 Dominic Lanzillotta. All rights reserved.
//

import UIKit

class AddPostTableViewController: UITableViewController {
    
    //MARK: - Outlets
    @IBOutlet weak var captionTextField: UITextField!
    
    //MARK: - Properties
    var postImage: UIImage?
    
    //MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        captionTextField.text = ""
    }
    
    //MARK: - Actions
    @IBAction func cancelButtonTapped(_ sender: UIBarButtonItem) {
        self.tabBarController?.selectedIndex = 0
    }
    
    @IBAction func addPostButtonTapped(_ sender: UIButton) {
        guard let caption = captionTextField.text, !caption.isEmpty, let image = postImage else {return}
        PostController.shared.createPostWith(image: image, caption: caption) { post in
            
        }
        self.tabBarController?.selectedIndex = 0
    }
    
    //MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //IIDOO
        if segue.identifier == "toChildVC" {
            guard let destinationVC = segue.destination as? PhotoSelectorViewController else {return}
            destinationVC.delegate = self
        }
    }
}
extension AddPostTableViewController: PhotoSelectorViewControllerDelegate {
    func photoSelectorViewControllerSelected(image: UIImage?) {
        self.postImage = image
    }
}
