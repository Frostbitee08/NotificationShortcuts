//
//  AppDelegate.swift
//  NotificationShortcuts
//
//  Created by Rocco Del Priore on 5/9/19.
//  Copyright © 2019 Rocco Del Priore. All rights reserved.
//

import Cocoa
import ShortcutRecorder

enum ShortCutIdentifier: String {
    case reply   = "NotificationShortCutsReply"
    case action  = "NotificationShortCutsAction"
    case dismiss = "NotificationShortCutsClose"
}

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!
    
    private var menuItemManager: MenuItemManager?

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        //Set Up Our Menu
        self.menuItemManager = MenuItemManager()
        
        //Set global shortcuts
        self.activateShortcuts()
        
        //Request accessibility access
        if checkAccessibilityAccess() == false {
            requestAccessibilityAccess()
        }
    }
    
    private func requestAccessibilityAccess() {
        let options: NSDictionary = [kAXTrustedCheckOptionPrompt.takeRetainedValue() as NSString: true]
        AXIsProcessTrustedWithOptions(options)
    }
    
    private func checkAccessibilityAccess() -> Bool{
        //get the value for accesibility
        let checkOptPrompt = kAXTrustedCheckOptionPrompt.takeRetainedValue() as NSString
        //set the options: false means it wont ask anyway
        let options = [checkOptPrompt: false]
        //translate into boolean value
        let accessEnabled = AXIsProcessTrustedWithOptions(options as CFDictionary?)
        return accessEnabled
    }

    func activateShortcuts() {
        let center = PTHotKeyCenter.shared()
        for shortCut in [ShortCutIdentifier.reply, ShortCutIdentifier.action, ShortCutIdentifier.dismiss] {
            if let keyCombo = PreferencesManager.sharedInstance.shortCutForIdentifier(identifier: shortCut) {
                //TODO: Figure out why this crashes with bad access
                //Unregister Existing Key/Pair
                //let oldHotKey = center?.hotKey(withIdentifier: shortCut.rawValue)
                //center?.unregisterHotKey(oldHotKey)
                
                //Register New Key/Pair
                let newHotKey = PTHotKey.init(identifier: shortCut.rawValue,
                                                keyCombo: keyCombo,
                                                  target: NotificationHandler.sharedInstance,
                                                  action: self.actionForIdentifier(identifier: shortCut))
                center?.register(newHotKey)
            }
        }
    }
    
    func actionForIdentifier(identifier: ShortCutIdentifier) -> Selector {
        switch identifier {
        case .reply:
            return #selector(NotificationHandler.replyToNotification)
        case .action:
            return #selector(NotificationHandler.activateNotification)
        case .dismiss:
            return #selector(NotificationHandler.closeNotification)
        }
    }
    
    func delayedSendNotification(sender: NSObject) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.sendNotification()
        }
    }
    
    func sendNotification() {
        let notification = NSUserNotification()
        notification.title = "Aloha 🤙"
        notification.subtitle = "This ole boy"
        notification.hasReplyButton = true
        
        NSUserNotificationCenter.default.deliver(notification)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            NotificationHandler.sharedInstance.replyToNotification()
        }
    }
}

