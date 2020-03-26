//
//  MenuItemManager.swift
//  NotificationShortcuts
//
//  Created by Rocco Del Priore on 5/10/19.
//  Copyright © 2019 Rocco Del Priore. All rights reserved.
//

import Foundation
import Sparkle
import Cocoa

class MenuItemManager: NSObject, NSMenuDelegate {
    private let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    private let menu = NSMenu(title: "menu")
    private var window: NSWindow? = nil
    
    override init() {
        super.init()
        
        self.menu.delegate            = self
        self.statusItem.image         = NSImage(named: "MenuIcon")
        self.statusItem.menu          = self.menu
        self.statusItem.isEnabled     = true
        self.statusItem.highlightMode = true
        
        self.reloadItemValues()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(reloadItemValues),
                                               name: PreferencesManager.shortcutsUpdatedNotification.name,
                                               object: nil)
    }
    
    //MARK: Actions
    @objc public func showPrefrences() {
        //Instantiate Window
        self.window = NSWindow.init(contentViewController: PreferencesViewController())
        self.window?.maxSize = PreferencesViewController.intrinsicContentSize
        self.window?.minSize = PreferencesViewController.intrinsicContentSize
        
        //Display Window
        self.window?.makeKeyAndOrderFront(NSApplication.shared.delegate)
        let windowController = NSWindowController(window: self.window)
        windowController.showWindow(NSApplication.shared.delegate)
        NSApp.activate(ignoringOtherApps: true)
    }
    
    @objc public func showSetup() {
        //Instantiate Window
        self.window = NSWindow.init(contentViewController: SetupViewController())
        self.window?.maxSize = SetupViewController.intrinsicContentSize
        self.window?.minSize = SetupViewController.intrinsicContentSize
        
        //Display Window
        self.window?.makeKeyAndOrderFront(NSApplication.shared.delegate)
        let windowController = NSWindowController(window: self.window)
        windowController.showWindow(NSApplication.shared.delegate)
        NSApp.activate(ignoringOtherApps: true)
    }
    
    @objc public func checkForUpdates() {
        SUUpdater.shared()?.checkForUpdates(self)
    }
    
    @objc public func quitApplication() {
        NSApplication.shared.terminate(self)
    }
    
    @objc public func reloadItemValues() {
        //Remove Previous Items
        self.menu.removeAllItems()
        
        //Instantiate Local Varibales
        let replyItem           = NSMenuItem(title: "Reply Shortcut", action: nil, keyEquivalent: "")
        let openItem            = NSMenuItem(title: "Open Shortcut", action: nil, keyEquivalent: "")
        let dismissItem         = NSMenuItem(title: "Dismiss Shortcut", action: nil, keyEquivalent: "")
        let seperatorItem1      = NSMenuItem.separator()
        let checkForUpdatesItem = NSMenuItem(title: "Check for Updates", action: #selector(self.checkForUpdates), keyEquivalent: "")
        let preferencesItem     = NSMenuItem(title: "Preferences", action: #selector(self.showPrefrences), keyEquivalent: ",")
        let seperatorItem2      = NSMenuItem.separator()
        let quitItem            = NSMenuItem(title: "Quit Notification Shotcuts", action: #selector(self.quitApplication), keyEquivalent: "q")
        
        //Set Properties
        checkForUpdatesItem.target = self
        preferencesItem.target = self
        quitItem.target = self
        
        //Configure for setup
        if !Setup.appHasAccessibilityAccess() {
            [replyItem, openItem, dismissItem].forEach { (item) in
                item.isEnabled = false
                item.state = .off
            }
            
            preferencesItem.title = "Set Up"
            preferencesItem.action = #selector(self.showSetup)
        }
        //Configure normally
        else {
            if let shortcut = PreferencesManager.sharedInstance.shortCutForIdentifier(identifier: ShortCutIdentifier.reply) {
                //replyItem.isEnabled = true
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
            if let shortcut = PreferencesManager.sharedInstance.shortCutForIdentifier(identifier: ShortCutIdentifier.open) {
                //openItem.isEnabled = true
                openItem.action = #selector(NotificationHandler.openNotification)
                openItem.target = NotificationHandler.sharedInstance
                if let keyEquivalent = shortcut["characters"] as? String {
                    openItem.keyEquivalent = keyEquivalent
                }
                if let flags = shortcut["modifierFlags"] as? String, let flagsInt = UInt(flags) {
                    openItem.keyEquivalentModifierMask = NSEvent.ModifierFlags(rawValue: flagsInt)
                }
            }
            else {
                openItem.isEnabled = false
            }
            if let shortcut = PreferencesManager.sharedInstance.shortCutForIdentifier(identifier: ShortCutIdentifier.dismiss) {
                //dismissItem.isEnabled = true
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
        }
        
        //Add Items
        self.menu.addItem(replyItem)
        self.menu.addItem(openItem)
        self.menu.addItem(dismissItem)
        self.menu.addItem(seperatorItem1)
        self.menu.addItem(checkForUpdatesItem)
        self.menu.addItem(preferencesItem)
        self.menu.addItem(seperatorItem2)
        self.menu.addItem(quitItem)
    }
}
