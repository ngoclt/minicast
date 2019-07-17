//
//  UIViewController+AlertView.swift
//  MiniCast
//
//  Created by Ngoc Le on 17/07/2019.
//  Copyright © 2019 Coder Life. All rights reserved.
//

import UIKit

extension UIViewController {
    
    func showAlert(title: String, message: String) {
        let okAlertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        let alertViewController = UIAlertController(title: title,
                                                    message: message,
                                                    preferredStyle: .alert)
        
        alertViewController.addAction(okAlertAction)
        present(alertViewController, animated: true, completion: nil)
    }
}

