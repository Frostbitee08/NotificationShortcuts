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

class PreferencesViewController: NSViewController, SRRecorderControlDelegate {
    static let intrinsicContentSize: NSSize  = NSSize(width: 340, height: 300)
    
    private let replyShortCut   = SRRecorderControl(frame: .zero)
    private let actionShortCut  = SRRecorderControl(frame: .zero)
    private let dismissShortCut = SRRecorderControl(frame: .zero)
    
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
        let actionStackView   = NSStackView(frame: .zero)
        let actionField       = NSTextField(frame: .zero)
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
        for field in [replyField, actionField, dismissField] {
            field.isBezeled       = false
            field.isEditable      = false
            field.isSelectable    = false
            field.drawsBackground = false
            field.backgroundColor = NSColor.clear
            field.font            = NSFont.systemFont(ofSize: 14)
            field.alignment       = .left
        }
        for stackView in [replyStackView, dismissStackView, actionStackView] {
            stackView.distribution = .fillEqually
            stackView.orientation  = .horizontal
        }
        for shortcutControl in [replyShortCut, actionShortCut, dismissShortCut] {
            shortcutControl.delegate = self
        }
        
        //Set Individual Properties
        self.title                     = "Notification Shortcuts"
        headerField.stringValue        = "Notification Shortcuts"
        headerField.font               = NSFont.systemFont(ofSize: 16, weight: NSFont.Weight.semibold)
        titleField.stringValue         = "Version 1.0 (2.31)"
        subtitleField.stringValue      = "Copyright © 2019 Particle Apps. All rights reserved."
        replyField.stringValue         = "Reply Global Shortcut:\t"
        actionField.stringValue        = "Action Global Shortcut:\t"
        dismissField.stringValue       = "Dismiss Global Shortcut:\t"
        shortCutStackView.distribution = .gravityAreas
        shortCutStackView.orientation  = .vertical
        shortCutStackView.alignment    = .left
        shortCutStackView.spacing      = 10
        
        //Add Subviews
        replyStackView.addArrangedSubview(replyField)
        replyStackView.addArrangedSubview(replyShortCut)
        actionStackView.addArrangedSubview(actionField)
        actionStackView.addArrangedSubview(actionShortCut)
        dismissStackView.addArrangedSubview(dismissField)
        dismissStackView.addArrangedSubview(dismissShortCut)
        shortCutStackView.addArrangedSubview(replyStackView)
        shortCutStackView.addArrangedSubview(actionStackView)
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
            make.top.equalTo(imageView.snp.bottom)
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
    func shortcutRecorder(_ aRecorder: SRRecorderControl!, canRecordShortcut aShortcut: [AnyHashable : Any]!) -> Bool {
        //        let validator = SRValidator(delegate: nil)
        //        let keyCode: NSNumber = aShortcut[SRShortcutKeyCode] as? NSNumber ?? NSNumber(integerLiteral: 0)
        //        let flags: NSNumber = aShortcut[SRShortcutModifierFlagsKey] as? NSNumber ?? NSNumber(integerLiteral: 0)
        //        var error: NSError? = nil
        //        var isTaken: Bool = validator?.isKeyCode(keyCode.uint16Value,
        //                                                 andFlagsTaken: NSEvent.ModifierFlags(rawValue: UInt(flags.uint16Value)),
        //                                                 error:&error) ?? true
        
        //TODO: Validate whether key/combo has been taken
        let isTaken             = false
        var identifier: String? = nil
        var action: Selector?   = nil
        
        //Set Variables
        if aRecorder == replyShortCut {
            identifier = "NotificationShortCutsReply"
            action     = #selector(NotificationHandler.replyToNotification)
        }
        else if aRecorder == actionShortCut {
            identifier = "NotificationShortCutsAction"
            action     = #selector(NotificationHandler.activateNotification)
        }
        else if aRecorder == dismissShortCut {
            identifier = "NotificationShortCutsClose"
            action     = #selector(NotificationHandler.closeNotification)
        }
        
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
                                          action: action)
            center?.register(newHotKey)
        }
        else {
            //TODO: Throw Error
        }
        
        return !isTaken
    }
}