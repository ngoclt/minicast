//
//  UIView+Layout.swift
//  MiniCast
//
//  Created by Ngoc Le on 11/06/2019.
//  Copyright © 2019 Coder Life. All rights reserved.
//

import UIKit

extension UIView {
    
    func pinEdges(to other: UIView) {
        leadingAnchor.constraint(equalTo: other.leadingAnchor).isActive = true
        trailingAnchor.constraint(equalTo: other.trailingAnchor).isActive = true
        topAnchor.constraint(equalTo: other.topAnchor).isActive = true
        bottomAnchor.constraint(equalTo: other.bottomAnchor).isActive = true
    }
}
