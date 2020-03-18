//
//  NotificationHandler.swift
//  NotificationShortcuts
//
//  Created by Rocco Del Priore on 5/10/19.
//  Copyright © 2019 Rocco Del Priore. All rights reserved.
//

import Cocoa
import Foundation

class NotificationHandler: NSObject {
    static let sharedInstance = NotificationHandler()
    private var mouseLocation: NSPoint? = nil
    
    //MARK: Helpers
    private func moveMouse(position: CGPoint) {
        NSCursor.setHiddenUntilMouseMoves(true)
        CGWarpMouseCursorPosition(position)
    }
    
    private func runAppleScript(source: String) -> NSAppleEventDescriptor {
        let script = NSAppleScript(source: source)!
        var error: NSDictionary?
        let output = script.executeAndReturnError(&error)
        print(output.stringValue ?? "")
        print("error: \(error as Any)")
        return output
    }
    
    private func isNotificationDisplayed() -> Bool {
        let source = """
set isNotificationDisplayed to false

tell application "System Events"
    tell process "Notification Center"
        set notificationCenterWindows to every window
        set numberOfWindows to count of notificationCenterWindows
        
        if numberOfWindows > 0 then
            set isNotificationDisplayed to true
        end if
    end tell
end tell

isNotificationDisplayed
"""
        return self.runAppleScript(source: source).booleanValue
    }
    
    //MARK: Public Actions
    @objc public func closeNotification() {
        if self.isNotificationDisplayed() {
            self.moveMouseToTarget()
            self.clickDismiss()
            self.moveMouseToOriginalLocation()
        }
    }
    
    @objc public func activateNotification() {
        if self.isNotificationDisplayed() {
            self.moveMouseToTarget()
            self.clickAction()
            self.moveMouseToOriginalLocation()
        }
    }
    
    @objc public func replyToNotification() {
        if self.isNotificationDisplayed() {
            self.moveMouseToTarget()
            self.clickReply()
            self.moveMouseToOriginalLocation()
        }
    }
    
    //MARK: Private Actions
    private func moveMouseToTarget() {
        self.mouseLocation = NSEvent.mouseLocation
        self.moveMouse(position: CGPoint(x: (NSScreen.screens.first?.frame.width ?? 70)-70, y: 60.0))
    }
    
    private func moveMouseToOriginalLocation() {
        if self.mouseLocation != nil {
            self.moveMouse(position: CGPoint(x: self.mouseLocation?.x ?? 0, y: self.mouseLocation?.y ?? 0))
            self.mouseLocation = nil
        }
    }
    
    private func clickReply() {
        let source = """
tell application "System Events"
    tell process "Notification Center"
        set theWindows to every window
        repeat with i from 1 to number of items in theWindows
            set this_item to item i of theWindows
            set someViews to buttons of this_item
            set cnt to count buttons of this_item
            
            if cnt > 1 then
                set reply to button 2 of this_item
                click reply
            else if cnt > 0 then
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
        let _ = self.runAppleScript(source: source)
    }
    
    private func clickAction() {
        let source = """
tell application "System Events"
    tell process "Notification Center"
        set theWindows to every window
        repeat with i from 1 to number of items in theWindows
            set this_item to item i of theWindows
            set someViews to buttons of this_item
            set cnt to count buttons of this_item
            
            if cnt > 1 then
                set action to button 2 of this_item
                click action
            else if cnt > 0 then
                set reply to button 1 of this_item
                click action
            end if
            
            log "Buttons: "
            log this_item
            log someViews
        end repeat
    end tell
end tell
"""
        let _ = self.runAppleScript(source: source)
    }
    
    private func clickDismiss() {
        let source = """
do shell script "killall NotificationCenter"
"""
        let _ = self.runAppleScript(source: source)
    }
}
