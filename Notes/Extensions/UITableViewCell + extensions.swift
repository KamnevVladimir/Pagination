//
//  UITableViewCell + extensions.swift
//  Notes
//
//  Created by Tsar on 20.04.2021.
//

import UIKit

extension UITableViewCell {
    static var nib : UINib{
        return UINib(nibName: identifier, bundle: nil)
    }
    
    static var identifier : String{
        return String(describing: self)
    }
}

