//
//  AppDelegate.swift
//  NotificationShortcuts
//
//  Created by Rocco Del Priore on 5/9/19.
//  Copyright © 2019 Rocco Del Priore. All rights reserved.
//

import Cocoa
import AppMover
import ShortcutRecorder

enum ShortCutIdentifier: String {
    case reply   = "NotificationShortCutsReply"
    case open    = "NotificationShortCutsOpen"
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
        
        //Move to Applications Folder if needed
        //TODO: Add a "Do not shot this message again" option https://github.com/potionfactory/LetsMove
        AppMover.moveIfNecessary(message: "I can move myself to the Applications folder if you'd like. This will keep your Downloads folder uncluttered.")
        
        //Request accessibility access
        if checkAccessibilityAccess() == false {
            requestAccessibilityAccess()
        }
        
        //Request script access
        self.requestScriptAccess()
    }
    
    //MARK: Helpers
    private func checkAccessibilityAccess() -> Bool{
        //get the value for accesibility
        let checkOptPrompt = kAXTrustedCheckOptionPrompt.takeRetainedValue() as NSString
        //set the options: false means it wont ask anyway
        let options = [checkOptPrompt: false]
        //translate into boolean value
        let accessEnabled = AXIsProcessTrustedWithOptions(options as CFDictionary?)
        return accessEnabled
    }
    
    //MARK: Actions
    private func requestScriptAccess() {
        let source = """
        tell application "System Events"
            tell process "Notification Center"
            end tell
        end tell
        """
        let script = NSAppleScript(source: source)!
        var error: NSDictionary?
        let _ = script.executeAndReturnError(&error)
    }
    
    private func requestAccessibilityAccess() {
        let options: NSDictionary = [kAXTrustedCheckOptionPrompt.takeRetainedValue() as NSString: true]
        AXIsProcessTrustedWithOptions(options)
    }

    func activateShortcuts() {
        for shortCutIdentifier in [ShortCutIdentifier.reply, ShortCutIdentifier.open, ShortCutIdentifier.dismiss] {
            guard
                let shortCutDictionary = PreferencesManager.sharedInstance.shortCutForIdentifier(identifier: shortCutIdentifier),
                let shortcut = Shortcut(dictionary: shortCutDictionary)
            else {
                continue
            }

            let shortcutAction = ShortcutAction(shortcut: shortcut,
                                                target: NotificationHandler.sharedInstance,
                                                action: actionForIdentifier(identifier: shortCutIdentifier),
                                                tag: 0)

            GlobalShortcutMonitor.shared.removeAllActions(forShortcut: shortcut)
            GlobalShortcutMonitor.shared.addAction(shortcutAction, forKeyEvent: .down)
        }
    }
    
    //MARK: Debug
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

