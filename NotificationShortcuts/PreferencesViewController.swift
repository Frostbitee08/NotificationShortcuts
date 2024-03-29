//
//  PreferencesViewController.swift
//  NotificationShortcuts
//
//  Created by Rocco Del Priore on 5/10/19.
//  Copyright © 2019 Rocco Del Priore. All rights reserved.
//

import Cocoa
import SnapKit
import LaunchAtLogin
import ShortcutRecorder

class PreferencesViewController: NSViewController, RecorderControlDelegate {
    static let intrinsicContentSize: NSSize  = NSSize(width: 340, height: 385)
    
    private let replyShortCut   = RecorderControl(frame: .zero)
    private let openShortCut    = RecorderControl(frame: .zero)
    private let dismissShortCut = RecorderControl(frame: .zero)
    private let optionsShortCut = RecorderControl(frame: .zero)
    private let startAtLoginButton = NSButton(frame: .zero)
    
    override func loadView() {
        self.view = NSView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Initialize Variables
        let imageView         = NSImageView(frame: .zero)
        let headerField       = NSTextField(frame: .zero)
        let titleField        = NSTextField(frame: .zero)
        let websiteField      = NSTextField(frame: .zero)
        let subtitleField     = NSTextField(frame: .zero)
        let shortCutStackView = NSStackView(frame: .zero)
        let replyStackView    = NSStackView(frame: .zero)
        let replyField        = NSTextField(frame: .zero)
        let openStackView     = NSStackView(frame: .zero)
        let openField         = NSTextField(frame: .zero)
        let dismissStackView  = NSStackView(frame: .zero)
        let dismissField      = NSTextField(frame: .zero)
        let optionsStackView  = NSStackView(frame: .zero)
        let optionsField      = NSTextField(frame: .zero)
        let websiteString: NSAttributedString = {
            let paragraph = NSMutableParagraphStyle()
            paragraph.alignment = .center
            let string = NSAttributedString(string: "https://notificationshortcuts.com",
                                            attributes: [NSAttributedString.Key.link: "https://notificationshortcuts.com",
                                                         NSAttributedString.Key.paragraphStyle: paragraph])
            return string
        }()
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        let buildVersion = Bundle.main.infoDictionary?["CFBundleVersion"] as? String

        //Set Group Properties
        for field in [headerField, titleField, websiteField, subtitleField] {
            field.isBezeled       = false
            field.isEditable      = false
            field.isSelectable    = false
            field.drawsBackground = false
            field.alignment       = .center
            field.backgroundColor = NSColor.clear
        }
        for field in [replyField, openField, dismissField, optionsField] {
            field.isBezeled       = false
            field.isEditable      = false
            field.isSelectable    = false
            field.drawsBackground = false
            field.backgroundColor = NSColor.clear
            field.font            = NSFont.systemFont(ofSize: 14)
            field.alignment       = .left
        }
        for stackView in [replyStackView, dismissStackView, openStackView, optionsStackView] {
            stackView.distribution = .fillEqually
            stackView.orientation  = .horizontal
        }
        for shortcutControl in [replyShortCut, openShortCut, dismissShortCut, optionsShortCut] {
            shortcutControl.delegate = self
        }
        
        //Set Individual Properties
        startAtLoginButton.setButtonType(NSButton.ButtonType.switch)
        startAtLoginButton.font        = NSFont.systemFont(ofSize: 14)
        startAtLoginButton.title       = "Start Notification Shortcuts at Login"
        startAtLoginButton.target      = self
        startAtLoginButton.action      = #selector(self.toggleStartAtLogin(sender:))
        startAtLoginButton.state       = LaunchAtLogin.isEnabled ? NSControl.StateValue.on : NSControl.StateValue.off
        self.title                     = "Preferences"
        imageView.image                = NSImage(named: "AppIcon")
        headerField.stringValue        = "Notification Shortcuts"
        headerField.font               = NSFont.systemFont(ofSize: 16, weight: NSFont.Weight.semibold)
        titleField.stringValue         = String.init(format: "Version %@ (%@)", appVersion ?? "?", buildVersion ?? "?")
        subtitleField.stringValue      = "Copyright © 2019 Particle Apps. All rights reserved."
        replyField.stringValue         = "Reply Global Shortcut:\t"
        openField.stringValue          = "Open Global Shortcut:\t"
        dismissField.stringValue       = "Dismiss Global Shortcut:\t"
        optionsField.stringValue       = "Options Global Shortcut:\t"
        shortCutStackView.distribution = .gravityAreas
        shortCutStackView.orientation  = .vertical
        shortCutStackView.alignment    = .left
        shortCutStackView.spacing      = 10
        websiteField.attributedStringValue = websiteString
        websiteField.isSelectable = true
        websiteField.allowsEditingTextAttributes = true
        
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
        setShortCutObjectValue(shortCutIdentifier: .options, control: optionsShortCut)
        
        //Add Subviews
        replyStackView.addArrangedSubview(replyField)
        replyStackView.addArrangedSubview(replyShortCut)
        openStackView.addArrangedSubview(openField)
        openStackView.addArrangedSubview(openShortCut)
        dismissStackView.addArrangedSubview(dismissField)
        dismissStackView.addArrangedSubview(dismissShortCut)
        optionsStackView.addArrangedSubview(optionsField)
        optionsStackView.addArrangedSubview(optionsShortCut)
        shortCutStackView.addArrangedSubview(replyStackView)
        shortCutStackView.addArrangedSubview(openStackView)
        shortCutStackView.addArrangedSubview(dismissStackView)
        shortCutStackView.addArrangedSubview(optionsStackView)
        self.view.addSubview(imageView)
        self.view.addSubview(headerField)
        self.view.addSubview(titleField)
        self.view.addSubview(websiteField)
        self.view.addSubview(subtitleField)
        self.view.addSubview(startAtLoginButton)
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
        websiteField.snp.makeConstraints { (make) in
            make.centerX.width.height.equalTo(titleField)
            make.top.equalTo(titleField.snp.bottom)
        }
        subtitleField.snp.makeConstraints { (make) in
            make.centerX.width.height.equalTo(titleField)
            make.top.equalTo(websiteField.snp.bottom)
        }
        startAtLoginButton.snp.makeConstraints { (make) in
            make.left.right.equalTo(subtitleField)
            make.top.equalTo(subtitleField.snp.bottom).offset(15)
            make.height.equalTo(25)
        }
        shortCutStackView.snp.makeConstraints { (make) in
            make.left.right.equalTo(startAtLoginButton)
            make.top.equalTo(startAtLoginButton.snp.bottom).offset(15)
            make.height.equalTo(45*shortCutStackView.arrangedSubviews.count)
        }
    }
    
    //MARK: Actions
     @objc private func toggleStartAtLogin(sender: NSButton) {
         LaunchAtLogin.isEnabled = !LaunchAtLogin.isEnabled
     }
    
    //MARK: Helpers
    private func shortCutIdentifier(for recorder: RecorderControl) -> ShortCutIdentifier? {
        if recorder == replyShortCut {
            return ShortCutIdentifier.reply
        }
        else if recorder == openShortCut {
            return ShortCutIdentifier.open
        }
        else if recorder == dismissShortCut {
            return ShortCutIdentifier.dismiss
        }
        else if recorder == optionsShortCut {
            return ShortCutIdentifier.options
        }
        return nil
    }
    
    //MARK: SRRecorderControl Delegate
    func recorderControlDidEndRecording(_ aControl: RecorderControl) {
        guard
            aControl.objectValue == nil,
            let identifier = self.shortCutIdentifier(for: aControl),
            let shortcutRaw = PreferencesManager.sharedInstance.shortCutForIdentifier(identifier: identifier),
            let shortcut = Shortcut(dictionary: shortcutRaw)
        else {
            return
        }
        
        //Remove shortcut
        GlobalShortcutMonitor.shared.removeAllActions(forShortcut: shortcut)
        PreferencesManager.sharedInstance.setShortCutForIdentifier(identifier: identifier,
                                                                   shortCut: [AnyHashable : Any]())
    }
    
    func recorderControl(_ aControl: RecorderControl, canRecord aShortcut: Shortcut) -> Bool {
        let isTaken                       = false
        
        if !isTaken, let identifier = self.shortCutIdentifier(for: aControl) {
            let shortcutAction = ShortcutAction(shortcut: aShortcut,
                                                target: NotificationHandler.sharedInstance,
                                                action: actionForIdentifier(identifier: identifier),
                                                tag: 0)
            
            GlobalShortcutMonitor.shared.removeAllActions(forShortcut: aShortcut)
            GlobalShortcutMonitor.shared.addAction(shortcutAction, forKeyEvent: .down)
            
            //Save Preference
            PreferencesManager.sharedInstance.setShortCutForIdentifier(identifier: identifier, shortCut: aShortcut.dictionaryRepresentation)
        }
        else {
            //TODO: Throw Error
            return false
        }
        
        return !isTaken
    }
}
