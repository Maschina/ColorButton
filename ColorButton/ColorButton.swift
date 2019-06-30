//
//  SceneButton.swift
//  HueMenuApp3
//
//  Created by Robert Hahn on 22.06.19.
//  Copyright © 2019 Robert Hahn. All rights reserved.
//

import Cocoa
import ReactiveKit
import Bond


@IBDesignable
class SceneButton: NSButton, CALayerDelegate {
    
    // MARK: - Public Properties
    
    public var backgroundColors = [NSColor]() { didSet { updateBackground() } }
    
    override var title: String { didSet { updateTitle() } }
    override var attributedTitle: NSAttributedString { didSet { updateAttributedTitle() } }
    
    @IBInspectable public var colorBackgroundMouseover: NSColor = NSColor.selectedMenuItemColor
    @IBInspectable public var colorFont: NSColor = NSColor.controlTextColor
    @IBInspectable public var colorFontMouseover: NSColor = NSColor.selectedMenuItemTextColor
    
    @IBInspectable public var buttonRadius: CGFloat = 5.0
    
    
    // MARK: - Private Properties
    
    private let rootLayer = CALayer()
    private let backgroundLayer = CAShapeLayer()
    private let backgroundGradientLayer = CAGradientLayer()
    private let mouseoverLayer = CAShapeLayer()
    private let titleLayer = SceneButtonTextLayer()
    
    private var mouseDown = Bool()
    private var mouseOver = Bool() { didSet { updateMouseover() } }
    
    private var recentAttrColor: NSColor?
    
    
    // MARK: - Setup & Initialization
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override init(frame: NSRect) {
        super.init(frame: frame)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Tracking area
        let trackingArea = NSTrackingArea(rect: bounds, options: [.activeAlways, .inVisibleRect, .mouseEnteredAndExited], owner: self, userInfo: nil)
        addTrackingArea(trackingArea)
        
        // Setup
        setup()
        setupBackground()
        setupMouseover()
        setupTitle()
    }
    
    override public var acceptsFirstResponder: Bool {
        return isEnabled
    }
    
    override public func becomeFirstResponder() -> Bool {
        return isEnabled
    }
    
    private func setup() {
        wantsLayer = true
        
        layer = rootLayer
        rootLayer.addSublayer(backgroundLayer)
        rootLayer.addSublayer(backgroundGradientLayer)
        rootLayer.addSublayer(mouseoverLayer)
        rootLayer.addSublayer(titleLayer)
        
    }
    
    private func setupBackground() {
        // Background
        backgroundLayer.frame = bounds
        backgroundLayer.path = backgroundLinedRect.cgPath
        
        // Gradient
        backgroundGradientLayer.frame = bounds
        backgroundGradientLayer.colors = backgroundColors.map({ $0.cgColor })
        backgroundGradientLayer.startPoint = CGPoint(x: 0, y: 0)
        backgroundGradientLayer.endPoint = CGPoint(x: 1, y: 0)
        backgroundGradientLayer.mask = backgroundLayer
    }
    
    private func updateBackground() {
        backgroundGradientLayer.colors = backgroundColors.map({ $0.cgColor })
    }
    
    private func setupMouseover() {
        mouseoverLayer.frame = bounds
        mouseoverLayer.path = mouseoverLinedRect.cgPath
        mouseoverLayer.fillColor = nil
    }
    
    private func updateMouseover() {
        if mouseOver {
            mouseoverLayer.fillColor = colorBackgroundMouseover.cgColor
            
            if titleLayer.hasAttributedTitle {
                recentAttrColor = self.attributedTitle.getForeColor()
                self.attributedTitle = self.attributedTitle.changeForeColor(color: colorFontMouseover)
                updateAttributedTitle()
            } else {
                titleLayer.foregroundColor = colorFontMouseover.cgColor
            }
            
        } else {
            mouseoverLayer.fillColor = nil
            
            if titleLayer.hasAttributedTitle {
                if let noHoverColor = recentAttrColor {
                    self.attributedTitle = self.attributedTitle.changeForeColor(color: noHoverColor)
                } else {
                    self.attributedTitle = self.attributedTitle.removeForeColor()
                }
                updateAttributedTitle()
            } else {
                titleLayer.foregroundColor = colorFont.cgColor
            }
        }
    }
    
    private func setupTitle() {
        titleLayer.frame = bounds
        titleLayer.alignmentMode = CATextLayerAlignmentMode.center
        
        if let font = font {
            titleLayer.font = font
            titleLayer.fontSize = font.pointSize
        }
        titleLayer.foregroundColor = colorFont.cgColor
        
        if let screen = NSScreen.main {
            titleLayer.contentsScale = screen.backingScaleFactor
        }
        
        // Default title
        titleLayer.string = title
    }
    
    private func updateTitle() {
        titleLayer.string = title
    }
    
    private func updateAttributedTitle() {
        titleLayer.string = attributedTitle
    }
    
    
    // MARK: - UI Sizing
    
    lazy var backgroundLinedRect: NSBezierPath = {
        let bezelFrame = bounds.insetBy(dx: 0, dy: 0)
        return NSBezierPath(roundedRect: bezelFrame, xRadius: buttonRadius, yRadius: buttonRadius)
    }()
    
    lazy var mouseoverLinedRect: NSBezierPath = {
        let bezelFrame = bounds.insetBy(dx: 2, dy: 2)
        return NSBezierPath(roundedRect: bezelFrame, xRadius: buttonRadius, yRadius: buttonRadius)
    }()
    
    
    // MARK: - Events
    
    override open func mouseDown(with event: NSEvent) {
        if isEnabled {
            mouseDown = true
        }
        super.mouseDown(with: event)
    }
    
    override func mouseUp(with event: NSEvent) {
        mouseDown = false
        super.mouseUp(with: event)
    }
    
    override open func mouseEntered(with event: NSEvent) {
        mouseOver = true
        super.mouseEntered(with: event)
    }
    
    override open func mouseExited(with event: NSEvent) {
        mouseOver = false
        super.mouseExited(with: event)
    }
    
    
    // MARK: - Drawing
    
    override open func draw(_ dirtyRect: NSRect) {
        
    }
    
    override public func drawFocusRingMask() {
        backgroundLinedRect.fill()
    }
    
    override public var focusRingMaskBounds: NSRect {
        return bounds.insetBy(dx: 1, dy: 1)
    }
}


class SceneButtonTextLayer: CATextLayer {
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


extension ReactiveExtensions where Base: SceneButton {
    
    internal var backgroundColors: Bond<[NSColor]> {
        return bond { $0.backgroundColors = $1 }
    }
}


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


extension NSBezierPath {
    var cgPath: CGPath {
        return self.transformToCGPath()
    }
    
    /// Transforms the NSBezierPath into a CGPathRef
    ///
    /// - Returns: The transformed NSBezierPath
    private func transformToCGPath() -> CGPath {
        // Create path
        let path = CGMutablePath()
        let points = UnsafeMutablePointer<NSPoint>.allocate(capacity: 3)
        let numElements = self.elementCount
        
        if numElements > 0 {
            for index in 0..<numElements {
                
                let pathType = self.element(at: index, associatedPoints: points)
                
                switch pathType {
                    
                case .moveTo:
                    path.move(to: points[0])
                case .lineTo:
                    path.addLine(to: points[0])
                case .curveTo:
                    path.addCurve(to: points[2], control1: points[0], control2: points[1])
                case .closePath:
                    path.closeSubpath()
                @unknown default:
                    continue
                }
            }
        }
        points.deallocate()
        return path
    }
}
