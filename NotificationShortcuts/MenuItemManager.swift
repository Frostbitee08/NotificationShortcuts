//
//  MenuItemManager.swift
//  NotificationShortcuts
//
//  Created by Rocco Del Priore on 5/10/19.
//  Copyright © 2019 Rocco Del Priore. All rights reserved.
//

import Foundation
import Cocoa

class MenuItemManager: NSObject, NSMenuDelegate {
    private let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    private let preferencesViewController = PreferencesViewController()
    private let menu = NSMenu(title: "menu")
    private var window: NSWindow? = nil
    
    override init() {
        super.init()
        
        self.menu.delegate            = self
        self.statusItem.image         = NSImage(named: "MenuIcon")
        self.statusItem.menu          = self.menu
        self.statusItem.isEnabled     = true
        self.statusItem.highlightMode = true
    }
    
    //MARK: Actions
    @objc private func showPrefrences() {
        //Instantiate Window
        self.window = NSWindow.init(contentViewController: self.preferencesViewController)
        self.window?.maxSize = PreferencesViewController.intrinsicContentSize
        self.window?.minSize = PreferencesViewController.intrinsicContentSize
        
        //Display Window
        self.window?.makeKeyAndOrderFront(NSApplication.shared.delegate)
        let windowController = NSWindowController(window: self.window)
        windowController.showWindow(NSApplication.shared.delegate)
        NSApp.activate(ignoringOtherApps: true)
    }
    
    @objc private func quitApplication() {
        NSApplication.shared.terminate(self)
    }
    
    //MARK: NSMenuDelegate
    func menuWillOpen(_ menu: NSMenu) {
        //Remove Previous Items
        self.menu.removeAllItems()
        
        //Instantiate Local Varibales
        let replyItem       = NSMenuItem(title: "Reply Shortcut", action: nil, keyEquivalent: "")
        let actionItem      = NSMenuItem(title: "Action Shortcut", action: nil, keyEquivalent: "")
        let dismissItem     = NSMenuItem(title: "Dismiss Shortcut", action: nil, keyEquivalent: "")
        let seperatorItem   = NSMenuItem.separator()
        let preferencesItem = NSMenuItem(title: "Preferences", action: #selector(self.showPrefrences), keyEquivalent: ",")
        let quitItem        = NSMenuItem(title: "Quit Notification Shotcuts", action: #selector(self.quitApplication), keyEquivalent: "q")
        //TODO: Add Check for Update
        
        //Set Properties
        preferencesItem.target = self
        quitItem.target = self
        
        //TODO: Get All Modifier Flags working
        if let shortcut = PreferencesManager.sharedInstance.shortCutForIdentifier(identifier: ShortCutIdentifier.reply) {
            replyItem.isEnabled = true
            replyItem.action = #selector(NotificationHandler.replyToNotification)
            replyItem.target = NotificationHandler.sharedInstance
            if let keyEquivalent = shortcut["characters"] as? String {
                replyItem.keyEquivalent = keyEquivalent
            }
            if let flags = shortcut["modifierFlags"] as? String, let flagsInt = UInt(flags) {
                replyItem.keyEquivalentModifierMask = NSEvent.ModifierFlags(rawValue: flagsInt)
            }
        }
        else {
            replyItem.isEnabled = false
        }
        if let shortcut = PreferencesManager.sharedInstance.shortCutForIdentifier(identifier: ShortCutIdentifier.action) {
            actionItem.isEnabled = true
            actionItem.action = #selector(NotificationHandler.activateNotification)
            actionItem.target = NotificationHandler.sharedInstance
            if let keyEquivalent = shortcut["characters"] as? String {
                actionItem.keyEquivalent = keyEquivalent
            }
            if let flags = shortcut["modifierFlags"] as? String, let flagsInt = UInt(flags) {
                actionItem.keyEquivalentModifierMask = NSEvent.ModifierFlags(rawValue: flagsInt)
            }
        }
        else {
            actionItem.isEnabled = false
        }
        if let shortcut = PreferencesManager.sharedInstance.shortCutForIdentifier(identifier: ShortCutIdentifier.dismiss) {
            dismissItem.isEnabled = true
            dismissItem.action = #selector(NotificationHandler.closeNotification)
            dismissItem.target = NotificationHandler.sharedInstance
            if let keyEquivalent = shortcut["characters"] as? String {
                dismissItem.keyEquivalent = keyEquivalent
            }
            if let flags = shortcut["modifierFlags"] as? String, let flagsInt = UInt(flags) {
                dismissItem.keyEquivalentModifierMask = NSEvent.ModifierFlags(rawValue: flagsInt)
            }
        }
        else {
            dismissItem.isEnabled = false
        }
        
        //Add Items
        self.menu.addItem(replyItem)
        self.menu.addItem(actionItem)
        self.menu.addItem(dismissItem)
        self.menu.addItem(seperatorItem)
        self.menu.addItem(preferencesItem)
        self.menu.addItem(quitItem)
    }
}
