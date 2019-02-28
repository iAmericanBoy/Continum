//
//  AppDelegate.swift
//  Continum
//
//  Created by Dominic Lanzillotta on 2/26/19.
//  Copyright © 2019 Dominic Lanzillotta. All rights reserved.
//

import UIKit
import CloudKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        isCKAccountAvailable { (isAvailable) in
            print(isAvailable ? "Account is available" : "Account is not available")            
        }
        return true
    }
    
    //MARK: - Private Functions
    func isCKAccountAvailable(completion: @escaping (Bool) -> Void) {
        CKContainer.default().accountStatus { (status, error) in
            if let error = error {
                print("An error loading CK account Status has occured: \(error), \(error.localizedDescription)")
                completion(false)
            }
            
            switch status {
            case .available:
                completion(true)
            case .noAccount:
                self.window?.rootViewController?.presentSimpleAlertWith(title: "Sign into iCloud in Settings", message: "No account found")
                completion(false)
            case .couldNotDetermine:
                self.window?.rootViewController?.tabBarController?.presentSimpleAlertWith(title: "Sign into iCloud in Settings", message: "There was an unknown error fetching your iCloud Account")
                completion(false)
            case .restricted:
                self.window?.rootViewController?.tabBarController?.presentSimpleAlertWith(title: "Sign into iCloud in Settings", message: "Your iCloud account is restricted")
                completion(false)
            }
        }
    }
}

