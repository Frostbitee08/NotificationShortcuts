//
//  AppDelegate.swift
//  NotificationShortcuts
//
//  Created by Rocco Del Priore on 5/9/19.
//  Copyright © 2019 Rocco Del Priore. All rights reserved.
//

import Cocoa
import ShortcutRecorder

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!
    
    private var menuItemManager: MenuItemManager?

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        self.menuItemManager = MenuItemManager()
        
        let options : NSDictionary = [kAXTrustedCheckOptionPrompt.takeRetainedValue() as NSString: true]
        let accessibilityEnabled = AXIsProcessTrustedWithOptions(options)
        print("RDP Accessibility Enabled: ", accessibilityEnabled)
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

