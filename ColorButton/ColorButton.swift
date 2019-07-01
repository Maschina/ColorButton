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
public class ColorButton: NSButton {
    
    // MARK: - Public Properties
    
    public var backgroundColors = [NSColor]() { didSet { updateBackground() } }
    
    override public var title: String { didSet { updateTitle() } }
    override public var attributedTitle: NSAttributedString { didSet { updateAttributedTitle() } }
    
    @IBInspectable public var colorBackgroundMouseover: NSColor = NSColor.selectedMenuItemColor
    @IBInspectable public var colorFont: NSColor = NSColor.controlTextColor
    @IBInspectable public var colorFontMouseover: NSColor = NSColor.selectedMenuItemTextColor
    
    @IBInspectable public var buttonRadius: CGFloat = 5.0
    
    
    // MARK: - Private Properties
    
    private let rootLayer = CALayer()
    private let backgroundLayer = CAShapeLayer()
    private let backgroundGradientLayer = CAGradientLayer()
    private let mouseoverLayer = CAShapeLayer()
    private let titleLayer = ColorButtonTextLayer()
    
    private var isMouseDown = Bool()
    private var isMouseOver = Bool() { didSet { updateMouseover() } }
    
    private var recentAttrColor: NSColor?
    
    
    // MARK: - Setup & Initialization
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override init(frame: NSRect) {
        super.init(frame: frame)
    }
    
    override public func awakeFromNib() {
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
    
    private func flashBackground() {
        // Begin the transaction
        CATransaction.begin()
        let backgroundFlashAnim = CABasicAnimation(keyPath: "fillColor")
        backgroundFlashAnim.fromValue = colorBackgroundMouseover.cgColor
        backgroundFlashAnim.toValue = nil
        mouseoverLayer.fillColor = nil
        backgroundFlashAnim.duration = 0
        backgroundFlashAnim.timeOffset = 0.25
        backgroundFlashAnim.repeatCount = 2
        
        // Callback function
        CATransaction.setCompletionBlock { [weak self] in
            self?.mouseoverLayer.fillColor = self?.colorBackgroundMouseover.cgColor
        }
        
        // Do the actual animation and commit the transaction
        mouseoverLayer.add(backgroundFlashAnim, forKey: "animateFillColor")
        CATransaction.commit()
    }
    
    private func setupMouseover() {
        mouseoverLayer.frame = bounds
        mouseoverLayer.path = mouseoverLinedRect.cgPath
        mouseoverLayer.fillColor = nil
    }
    
    private func updateMouseover() {
        if isMouseOver {
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
    
    override public func mouseDown(with event: NSEvent) {
        // Mouse down
        if isEnabled {
            isMouseDown = true
        }
        super.mouseDown(with: event)
        
        // Mouse up
        isMouseDown = false
        flashBackground()
    }
    
    override public func mouseEntered(with event: NSEvent) {
        isMouseOver = true
        super.mouseEntered(with: event)
    }
    
    override public func mouseExited(with event: NSEvent) {
        isMouseOver = false
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
