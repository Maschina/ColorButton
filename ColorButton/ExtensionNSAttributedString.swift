//
//  ExtensionNSAttributedString.swift
//  ColorButton
//
//  Created by Robert Hahn on 30.06.19.
//  Copyright © 2019 Robert Hahn. All rights reserved.
//

import Cocoa


extension NSAttributedString {
    func changeForeColor(color: NSColor) -> NSAttributedString {
        let attrString = NSMutableAttributedString(attributedString: self)
        attrString.addAttribute(NSAttributedString.Key.foregroundColor, value: color, range: NSRange(location: 0, length: self.string.count))
        return attrString
    }
    
    func removeForeColor() -> NSAttributedString {
        let attrString = NSMutableAttributedString(attributedString: self)
        attrString.removeAttribute(NSAttributedString.Key.foregroundColor, range: NSRange(location: 0, length: self.string.count))
        return attrString
    }
    
    func getForeColor() -> NSColor? {
        guard let color = self.attribute(NSAttributedString.Key.foregroundColor, at: 0, effectiveRange: nil) as? NSColor else { return nil }
        return color
    }
}
