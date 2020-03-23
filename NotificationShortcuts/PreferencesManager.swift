//
//  PreferencesManager.swift
//  NotificationShortcuts
//
//  Created by Rocco Del Priore on 5/13/19.
//  Copyright © 2019 Rocco Del Priore. All rights reserved.
//

import Cocoa

class PreferencesManager: NSObject {
    static let sharedInstance = PreferencesManager()
    private let preferencesPath: String = {
        var path = NSString(string: NSHomeDirectory())
        return path.appendingPathComponent("Library/Application Support/NotificationShortcuts").appending("/Preferences.plist")
    }()
    private var preferences = NSMutableDictionary()
    
    override init() {
        super.init()
        
        if FileManager.default.fileExists(atPath: self.preferencesPath) {
            self.readPreferencesFile()
        }
        else {
            self.createPreferencesFile()
        }
    }
    
    //MARK: Actions
    private func createPreferencesFile() {
        let preferencesDirectoryPath = NSString(string: self.preferencesPath).deletingPathExtension
        self.preferences = [
            ShortCutIdentifier.reply.rawValue: "",
            ShortCutIdentifier.open.rawValue: "",
            ShortCutIdentifier.dismiss.rawValue: "",
        ]
        
        if !FileManager.default.fileExists(atPath: preferencesDirectoryPath, isDirectory: nil) {
            do {
                try FileManager.default.createDirectory(atPath: preferencesDirectoryPath, withIntermediateDirectories: true, attributes: nil)
                self.writeToPreferencesFile()
            } catch let error as NSError {
                print(error.localizedDescription);
            }
        }
    }
    private func readPreferencesFile() {
        self.preferences = NSMutableDictionary(contentsOfFile: self.preferencesPath) ?? NSMutableDictionary()
        
    }
    private func writeToPreferencesFile() {
        self.preferences.write(toFile: self.preferencesPath, atomically: true)
    }
    
    //MARK: Accessors
    public func shortCutForIdentifier(identifier: ShortCutIdentifier) -> [AnyHashable : Any]? {
        if let shortCut = self.preferences.value(forKey: identifier.rawValue) as? [AnyHashable : Any] {
            return shortCut
        }
        return nil
    }
    
    //MARK: Modifiers
    public func setShortCutForIdentifier(identifier: ShortCutIdentifier, shortCut: [AnyHashable : Any]) {
        self.preferences.setValue(shortCut, forKey: identifier.rawValue)
        self.writeToPreferencesFile()
    }
}
