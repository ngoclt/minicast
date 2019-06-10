//
//  Reusable.swift
//  MiniCast
//
//  Created by Ngoc Le on 07/06/2019.
//  Copyright © 2019 Coder Life. All rights reserved.
//

import Foundation

protocol Identifiable: class {
    static var identifier: String { get }
}

extension Identifiable {
    static var identifier: String {
        /// Use the class's name as an identifier
        return String(describing: Self.self)
    }
}
