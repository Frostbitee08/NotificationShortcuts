//
//  PreferencesViewController.swift
//  NotificationShortcuts
//
//  Created by Rocco Del Priore on 5/10/19.
//  Copyright © 2019 Rocco Del Priore. All rights reserved.
//

import Cocoa
import SnapKit
import ShortcutRecorder

class PreferencesViewController: NSViewController, RecorderControlDelegate {
    static let intrinsicContentSize: NSSize  = NSSize(width: 340, height: 300)
    
    private let replyShortCut   = RecorderControl(frame: .zero)
    private let openShortCut    = RecorderControl(frame: .zero)
    private let dismissShortCut = RecorderControl(frame: .zero)
    
    override func loadView() {
        self.view = NSView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Initialize Variables
        let imageView         = NSImageView(frame: .zero)
        let headerField       = NSTextField(frame: .zero)
        let titleField        = NSTextField(frame: .zero)
        let subtitleField     = NSTextField(frame: .zero)
        let shortCutStackView = NSStackView(frame: .zero)
        let replyStackView    = NSStackView(frame: .zero)
        let replyField        = NSTextField(frame: .zero)
        let openStackView     = NSStackView(frame: .zero)
        let openField         = NSTextField(frame: .zero)
        let dismissStackView  = NSStackView(frame: .zero)
        let dismissField      = NSTextField(frame: .zero)

        //Set Group Properties
        for field in [headerField, titleField, subtitleField] {
            field.isBezeled       = false
            field.isEditable      = false
            field.isSelectable    = false
            field.drawsBackground = false
            field.alignment       = .center
            field.backgroundColor = NSColor.clear
        }
        for field in [replyField, openField, dismissField] {
            field.isBezeled       = false
            field.isEditable      = false
            field.isSelectable    = false
            field.drawsBackground = false
            field.backgroundColor = NSColor.clear
            field.font            = NSFont.systemFont(ofSize: 14)
            field.alignment       = .left
        }
        for stackView in [replyStackView, dismissStackView, openStackView] {
            stackView.distribution = .fillEqually
            stackView.orientation  = .horizontal
        }
        for shortcutControl in [replyShortCut, openShortCut, dismissShortCut] {
            shortcutControl.delegate = self
        }
        
        //Set Individual Properties
        self.title                     = "Preferences"
        imageView.image                = NSImage(named: "AppIcon")
        headerField.stringValue        = "Notification Shortcuts"
        headerField.font               = NSFont.systemFont(ofSize: 16, weight: NSFont.Weight.semibold)
        titleField.stringValue         = "Version 1.0 (2.31)"
        subtitleField.stringValue      = "Copyright © 2019 Particle Apps. All rights reserved."
        replyField.stringValue         = "Reply Global Shortcut:\t"
        openField.stringValue        = "Open Global Shortcut:\t"
        dismissField.stringValue       = "Dismiss Global Shortcut:\t"
        shortCutStackView.distribution = .gravityAreas
        shortCutStackView.orientation  = .vertical
        shortCutStackView.alignment    = .left
        shortCutStackView.spacing      = 10
        
        func setShortCutObjectValue(shortCutIdentifier: ShortCutIdentifier, control: RecorderControl) {
            guard
                let shortCutDictionary = PreferencesManager.sharedInstance.shortCutForIdentifier(identifier: shortCutIdentifier),
                let shortCut = Shortcut(dictionary: shortCutDictionary)
            else {
                return
            }
            
            control.objectValue = shortCut
        }
        
        setShortCutObjectValue(shortCutIdentifier: .reply, control: replyShortCut)
        setShortCutObjectValue(shortCutIdentifier: .open, control: openShortCut)
        setShortCutObjectValue(shortCutIdentifier: .dismiss, control: dismissShortCut)
        
        //Add Subviews
        replyStackView.addArrangedSubview(replyField)
        replyStackView.addArrangedSubview(replyShortCut)
        openStackView.addArrangedSubview(openField)
        openStackView.addArrangedSubview(openShortCut)
        dismissStackView.addArrangedSubview(dismissField)
        dismissStackView.addArrangedSubview(dismissShortCut)
        shortCutStackView.addArrangedSubview(replyStackView)
        shortCutStackView.addArrangedSubview(openStackView)
        shortCutStackView.addArrangedSubview(dismissStackView)
        self.view.addSubview(imageView)
        self.view.addSubview(headerField)
        self.view.addSubview(titleField)
        self.view.addSubview(subtitleField)
        self.view.addSubview(shortCutStackView)
        
        //Set Constrains
        self.view.snp.makeConstraints { (make) in
            make.height.equalTo(PreferencesViewController.intrinsicContentSize.height)
            make.width.equalTo(PreferencesViewController.intrinsicContentSize.width)
        }
        imageView.snp.makeConstraints { (make) in
            make.top.equalTo(self.view).offset(15)
            make.centerX.equalTo(self.view)
            make.height.width.equalTo(70)
        }
        headerField.snp.makeConstraints { (make) in
            make.centerX.equalTo(self.view)
            make.top.equalTo(imageView.snp.bottom).offset(10)
            make.width.equalTo(self.view).offset(-30)
            make.height.equalTo(25)
        }
        titleField.snp.makeConstraints { (make) in
            make.height.equalTo(20)
            make.centerX.equalTo(self.view)
            make.width.equalTo(headerField)
            make.top.equalTo(headerField.snp.bottom)
        }
        subtitleField.snp.makeConstraints { (make) in
            make.centerX.width.height.equalTo(titleField)
            make.top.equalTo(titleField.snp.bottom)
        }
        shortCutStackView.snp.makeConstraints { (make) in
            make.left.right.equalTo(subtitleField)
            make.top.equalTo(subtitleField.snp.bottom).offset(25)
            make.height.equalTo(45*shortCutStackView.arrangedSubviews.count)
        }
    }
    
    //MARK: SRRecorderControl Delegate
    func shortcutRecorder(_ aRecorder: RecorderControl, canRecordShortcut aShortcut: [AnyHashable : Any]) -> Bool {
        guard let shortcut = Shortcut(dictionary: aShortcut) else {
            return false
        }
        
        let isTaken                       = false
        var shortCutIdentifier: ShortCutIdentifier? = nil
        
        //Set Variables
        if aRecorder == replyShortCut {
            shortCutIdentifier = ShortCutIdentifier.reply
        }
        else if aRecorder == openShortCut {
            shortCutIdentifier = ShortCutIdentifier.open
        }
        else if aRecorder == dismissShortCut {
            shortCutIdentifier   = ShortCutIdentifier.dismiss
        }
        
        if !isTaken, let identifier = shortCutIdentifier {
            let shortcutAction = ShortcutAction(shortcut: shortcut,
                                                target: NotificationHandler.sharedInstance,
                                                action: actionForIdentifier(identifier: identifier),
                                                tag: 0)
            
            GlobalShortcutMonitor.shared.removeAllActions(forShortcut: shortcut)
            GlobalShortcutMonitor.shared.addAction(shortcutAction, forKeyEvent: .down) 
            
            //Save Preference
            PreferencesManager.sharedInstance.setShortCutForIdentifier(identifier: identifier, shortCut: aShortcut)
        }
        else {
            //TODO: Throw Error
            return false
        }
        
        return !isTaken
    }
    
    func shortcutRecorderShouldBeginRecording(_ aRecorder: RecorderControl) -> Bool {
        GlobalShortcutMonitor.shared.pause()
        return true
    }
    private func shortcutRecorderDidEndRecording(_ aRecorder: RecorderControl) {
        GlobalShortcutMonitor.shared.resume()
    }
}
