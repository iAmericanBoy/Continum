//
//  ViewController+extension.swift
//  Continum
//
//  Created by Dominic Lanzillotta on 2/28/19.
//  Copyright © 2019 Dominic Lanzillotta. All rights reserved.
//

import UIKit

extension UIViewController {
    func presentSimpleAlertWith(title: String, message: String?) {
        let simpleAlert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let dismissAction = UIAlertAction(title: "Dismiss", style: .cancel, handler: nil)
        simpleAlert.addAction(dismissAction)
        
        self.present(simpleAlert, animated: true)
    }
}
