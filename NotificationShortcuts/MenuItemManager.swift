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
        self.window = nil
        //TODO: Implement
    }
    
    @objc private func quitApplication() {
        NSApplication.shared.terminate(self)
    }
    
    //MARK: NSMenuDelegate
    func menuWillOpen(_ menu: NSMenu) {
        //Remove Previous Items
        self.menu.removeAllItems()
        
        //Instantiate Local Varibales
        let preferencesItem = NSMenuItem(title: "Preferences", action: #selector(self.showPrefrences), keyEquivalent: ",")
        let quitItem = NSMenuItem(title: "Quit Notification Shotcuts", action: #selector(self.quitApplication), keyEquivalent: "q")
        //TODO: Add Check for Update
        //TODO: Add Indicators for current shortcuts
        
        //Set Properties
        preferencesItem.target = self
        quitItem.target = self
        
        //Add Items
        self.menu.addItem(preferencesItem)
        self.menu.addItem(quitItem)
    }
}
