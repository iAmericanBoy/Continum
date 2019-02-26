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
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var selectImageButton: UIButton!
    @IBOutlet weak var captionTextField: UITextField!
    
    //MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        selectImageButton.setTitle("SelectImage", for: .normal)
        postImageView.image = nil
    }
    
    //MARK: - Actions
    @IBAction func cancelButtonTapped(_ sender: UIBarButtonItem) {
        self.tabBarController?.selectedIndex = 0
    }
    
    @IBAction func selectImageButtonTapped(_ sender: UIButton) {
        postImageView.image = UIImage(named: "spaceEmptyState")
        self.selectImageButton.setTitle("", for: .normal)
    }
    
    @IBAction func addPostButtonTapped(_ sender: UIButton) {
        guard let caption = captionTextField.text, !caption.isEmpty, let image = postImageView.image else {return}
        PostController.shared.createPostWith(image: image, caption: caption) { post in
            
        }
        self.tabBarController?.selectedIndex = 0
    }
    
}
