//
//  ColorButtonTextLayer.swift
//  ColorButton
//
//  Created by Robert Hahn on 30.06.19.
//  Copyright © 2019 Robert Hahn. All rights reserved.
//

import Cocoa


class ColorButtonTextLayer: CATextLayer {
    public var hasAttributedTitle: Bool {
        return ((self.string as? NSAttributedString) != nil)
    }
    
    override open func draw(in ctx: CGContext) {
        let yDiff: CGFloat
        let fontSize: CGFloat
        let height = self.bounds.height
        
        if let attributedString = self.string as? NSAttributedString {
            fontSize = attributedString.size().height
            yDiff = (height-fontSize)/2
        } else {
            fontSize = self.fontSize
            yDiff = (height-fontSize)/2 - fontSize/10
        }
        
        ctx.saveGState()
        ctx.translateBy(x: 0.0, y: yDiff)
        super.draw(in: ctx)
        ctx.restoreGState()
    }
}
