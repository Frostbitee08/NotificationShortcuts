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
    static let sharedInstance  = NotificationHandler()
    
    @objc public func closeNotification() {
        self.moveMouse()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.clickDismiss()
        }
    }
    
    @objc public func activateNotification() {
        self.moveMouse()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.clickAction()
        }
    }
    
    @objc public func replyToMessage() {
        self.moveMouse()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.clickReply()
        }
    }
    
    private func moveMouse() {
        NSCursor.setHiddenUntilMouseMoves(true)
        //TODO: Set Coordinate Dynamically Here
        CGWarpMouseCursorPosition(CGPoint(x: 1370.0, y: 60.0))
    }
    
    private func runAppleScript(source: String) {
        let script = NSAppleScript(source: source)!
        var error: NSDictionary?
        let output = script.executeAndReturnError(&error)
        print(output.stringValue ?? "")
        print("error: \(error as Any)")
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
        self.runAppleScript(source: source)
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
        self.runAppleScript(source: source)
    }
    
    private func clickDismiss() {
        //TODO: Implement dismisal for all notifications
        let source = """
tell application "System Events"
    tell process "Notification Center"
        set theWindows to every window
        repeat with i from 1 to number of items in theWindows
            set this_item to item i of theWindows
            set someViews to buttons of this_item
            set cnt to count buttons of this_item
            
            if cnt > 1 then
                set action to button 1 of this_item
                click action
            end if
            
            log "Buttons: "
            log this_item
            log someViews
        end repeat
    end tell
end tell
"""
        self.runAppleScript(source: source)
    }
}
