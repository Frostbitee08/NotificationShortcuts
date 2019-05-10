//
//  AppDelegate.swift
//  NotificationShortcuts
//
//  Created by Rocco Del Priore on 5/9/19.
//  Copyright © 2019 Rocco Del Priore. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!


    func applicationDidFinishLaunching(_ aNotification: Notification) {
        
    }
    
    @IBAction func delayedSendNotification(sender: NSObject) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.sendNotification()
            //self.testMe()
        }
    }
    
    func sendNotification() {
        let notification = NSUserNotification()
        notification.title = "Aloha 🤙"
        notification.subtitle = "This ole boy"
        //notification.actionButtonTitle = "Yeah Boy"
        notification.hasReplyButton = true
        //notification.hasActionButton = true
        
        NSUserNotificationCenter.default.deliver(notification)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            //self.sendNotification()
            self.testMe()
        }
    }
    
    func mouseMoveAndClick(onPoint point: CGPoint) {
        print("RDP Move Mouse & Click")
        guard let moveEvent = CGEvent(mouseEventSource: nil, mouseType: .mouseMoved, mouseCursorPosition: point, mouseButton: .left) else {
            return
        }
        guard let downEvent = CGEvent(mouseEventSource: nil, mouseType: .leftMouseDown, mouseCursorPosition: point, mouseButton: .left) else {
            return
        }
        guard let upEvent = CGEvent(mouseEventSource: nil, mouseType: .leftMouseUp, mouseCursorPosition: point, mouseButton: .left) else {
            return
        }
        moveEvent.post(tap: CGEventTapLocation.cghidEventTap)
        downEvent.post(tap: CGEventTapLocation.cghidEventTap)
        upEvent.post(tap: CGEventTapLocation.cghidEventTap)
    }
    
    func testMe() {
        NSCursor.setHiddenUntilMouseMoves(true)
        CGWarpMouseCursorPosition(CGPoint(x: 1370.0, y: 60.0))
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            self.runAppleScript()
            //self.simulateMouseClick(.left)
        }
    }

    func runAppleScript() {
        let source = """
tell application "System Events"
    tell process "Notification Center"
        set theWindows to every window
        repeat with i from 1 to number of items in theWindows
            set this_item to item i of theWindows
            set someViews to buttons of this_item
            set cnt to count buttons of this_item
            
            if cnt > 0 then
                set reply to button 1 of this_item
                click reply
            end if
            
            log "Buttons: "
            log this_item
            log someViews
        end repeat
    end tell
end tell
"""
        
        let script = NSAppleScript(source: source)!
        var error: NSDictionary?
        let output = script.executeAndReturnError(&error)
        print(output.stringValue ?? "")
        print("error: \(error as Any)")
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }


}

