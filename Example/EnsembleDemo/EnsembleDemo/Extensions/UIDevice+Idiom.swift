//
//  UIDevice+Idiom.swift
//  EnsembleDemo
//
//  Created by Cole Roberts on 2/20/23.
//

import UIKit

extension UIDevice {
    static var isPad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }
    
    static var isPhone: Bool {
        UIDevice.current.userInterfaceIdiom == .phone
    }
}
