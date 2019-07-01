//
//  AppDelegate.swift
//  ColorButton-App
//
//  Created by Robert Hahn on 30.06.19.
//  Copyright © 2019 Robert Hahn. All rights reserved.
//

import Cocoa
import ColorButton


@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!
    @IBOutlet weak var button: ColorButton!
    

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        button.backgroundColors = [NSColor.white, NSColor.yellow]
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
}

