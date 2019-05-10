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
class AppDelegate: NSObject, NSApplicationDelegate, SRRecorderControlDelegate {

    @IBOutlet weak var window: NSWindow!
    
    private var menuItemManager: MenuItemManager?

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        self.menuItemManager = MenuItemManager()
    }
    
    func shortcutRecorder(_ aRecorder: SRRecorderControl!, canRecordShortcut aShortcut: [AnyHashable : Any]!) -> Bool {
//        let validator = SRValidator(delegate: nil)
//        let keyCode: NSNumber = aShortcut[SRShortcutKeyCode] as? NSNumber ?? NSNumber(integerLiteral: 0)
//        let flags: NSNumber = aShortcut[SRShortcutModifierFlagsKey] as? NSNumber ?? NSNumber(integerLiteral: 0)
//        var error: NSError? = nil
//        var isTaken: Bool = validator?.isKeyCode(keyCode.uint16Value,
//                                                 andFlagsTaken: NSEvent.ModifierFlags(rawValue: UInt(flags.uint16Value)),
//                                                 error:&error) ?? true
        
        //TODO: Validate whether key/combo has been taken
        let isTaken = false
        let identifier = "NotificationShortCutsReply"
        
        if !isTaken {
            //Declare Variables
            let center = PTHotKeyCenter.shared()
            
            //Unregister Existing Key/Pair
            let oldHotKey = center?.hotKey(withIdentifier: identifier)
            center?.unregisterHotKey(oldHotKey)
            
            //Register New Key/Pair
            let newHotKey = PTHotKey.init(identifier: identifier,
                                          keyCombo: aShortcut,
                                          target: NotificationHandler.sharedInstance,
                                          action: #selector(NotificationHandler.replyToMessage))
            center?.register(newHotKey)
        }
        else {
            //TODO: Throw Error
        }
        
        return !isTaken
    }
    
    func delayedSendNotification(sender: NSObject) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.sendNotification()
            //self.testMe()
        }
    }
    
    func sendNotification() {
        let notification = NSUserNotification()
        notification.title = "Aloha 🤙"
        notification.subtitle = "This ole boy"
        notification.hasReplyButton = true
        
        NSUserNotificationCenter.default.deliver(notification)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            NotificationHandler.sharedInstance.replyToMessage()
        }
    }
}

