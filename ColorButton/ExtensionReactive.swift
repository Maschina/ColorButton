//
//  ExtensionReactive.swift
//  ColorButton
//
//  Created by Robert Hahn on 30.06.19.
//  Copyright © 2019 Robert Hahn. All rights reserved.
//

import Cocoa
import ReactiveKit
import Bond


extension ReactiveExtensions where Base: SceneButton {
    
    internal var backgroundColors: Bond<[NSColor]> {
        return bond { $0.backgroundColors = $1 }
    }
}
