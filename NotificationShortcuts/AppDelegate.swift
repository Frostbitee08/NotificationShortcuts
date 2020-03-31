//
//  AppDelegate.swift
//  NotificationShortcuts
//
//  Created by Rocco Del Priore on 5/9/19.
//  Copyright © 2019 Rocco Del Priore. All rights reserved.
//

import Cocoa
import Sparkle
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
        //Configure Sparkle
        if let urlString = Bundle.main.object(forInfoDictionaryKey: "SUFeedURL") as? String, let url = URL(string: urlString) {
            SUUpdater.shared()?.feedURL = url
            SUUpdater.shared()?.checkForUpdatesInBackground()
        }
        
        //Set Up Our Menu
        self.menuItemManager = MenuItemManager()
        
        //Set global shortcuts
        let userHasShortcuts = self.activateShortcuts()
        
        //Move to Applications Folder if needed
        //TODO: Add a "Do not shot this message again" option https://github.com/potionfactory/LetsMove
        AppMover.moveIfNecessary(message: "I can move myself to the Applications folder if you'd like. This will keep your Downloads folder uncluttered.")
        
        //Request accessibility access
        if !Setup.appHasAccessibilityAccess() {
            self.menuItemManager?.showSetup()
        }
        //Request script access
        else if !Setup.appHasScriptAccess() {
            self.menuItemManager?.showSetup()
        }
        //Prompt user to set shortcuts if needed
        else if !userHasShortcuts {
            self.menuItemManager?.showPrefrences()
        }
        
        //Monitor for accesibility changes
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(setupCompletionDidChange),
                                               name: Setup.setupCompletionChangedNotification.name,
                                               object: nil)
    }
    
    //MARK: Actions
    func activateShortcuts() -> Bool {
        var activatedAtLeastOneShortcut = false
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
            
            activatedAtLeastOneShortcut = true
        }
        
        return activatedAtLeastOneShortcut
    }
    
    @objc private func setupCompletionDidChange() {
        self.menuItemManager?.reloadItemValues()
        
        if Setup.completed && !self.activateShortcuts() {
            self.menuItemManager?.showPrefrences()
        }
        else if !Setup.completed {
            self.menuItemManager?.showSetup()
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

