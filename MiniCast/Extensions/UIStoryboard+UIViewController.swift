//
//  UIStoryboard+UIViewController.swift
//  MiniCast
//
//  Created by Ngoc Le on 07/06/2019.
//  Copyright © 2019 Coder Life. All rights reserved.
//

import UIKit

enum AppStoryboard: String {
    case main = "Main"
    
    private var instance : UIStoryboard {
        return UIStoryboard(name: self.rawValue, bundle: Bundle.main)
    }
}

extension AppStoryboard {
    
    func instantiate<T: UIViewController>() -> T? where T: Identifiable {
        return instance.instantiateViewController(withIdentifier: T.identifier) as? T
    }
}
