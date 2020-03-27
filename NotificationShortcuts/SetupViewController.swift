//
//  SetupViewController.swift
//  NotificationShortcuts
//
//  Created by Rocco Del Priore on 3/26/20.
//  Copyright © 2020 Rocco Del Priore. All rights reserved.
//

import Foundation
import Cocoa
import SnapKit

class Setup {
    static let accessibilityAccessChangedNotification = Notification.init(name: Notification.Name.init("AccessibilityAccessChanged"))
    static func appHasAccessibilityAccess() -> Bool{
        //get the value for accesibility
        let checkOptPrompt = kAXTrustedCheckOptionPrompt.takeRetainedValue() as NSString
        //set the options: false means it wont ask anyway
        let options = [checkOptPrompt: false]
        //translate into boolean value
        let accessEnabled = AXIsProcessTrustedWithOptions(options as CFDictionary?)
        return accessEnabled
    }

    static func requestAccessibilityAccess() {
        let options: NSDictionary = [kAXTrustedCheckOptionPrompt.takeRetainedValue() as NSString: true]
        AXIsProcessTrustedWithOptions(options)
    }
}

fileprivate enum SetupStep:Int {
    case one = 0
    case two = 1
    case three = 2
}

fileprivate class SetupStepButton: NSView {
    public var isEnabled = false {
        didSet {
            if #available(OSX 10.13, *) {
                let whiteColor = NSColor(named: "WhiteColor")
                let blackColor = NSColor(named: "BlackColor")
                self.indexField.textColor = self.isEnabled ? whiteColor : NSColor(named: "BackgroundColor")
                self.indexField.backgroundColor = self.isEnabled ? blackColor : .lightGray
                self.titleField.textColor = self.isEnabled ? blackColor : .lightGray
            } else {
                self.indexField.textColor = self.isEnabled ? .white : NSColor(red:0.93, green:0.93, blue:0.93, alpha:1.00)
                self.indexField.backgroundColor = self.isEnabled ? .black : .lightGray
                self.titleField.textColor = self.isEnabled ? .black : .lightGray
            }
        }
    }
    public var step: SetupStep = .one {
        didSet {
            self.indexField.stringValue = String(format: "%i", self.step.rawValue+1)
        }
    }
    public var title: String = "" {
        didSet {
            self.titleField.stringValue = self.title
        }
    }
    public var isActionEnabled = true
    public var target: AnyObject? = nil
    public var action: Selector? = nil
    
    private let indexFieldSize: CGFloat = 22.0
    private let indexField: NSTextField = {
        let field = NSTextField()
        field.font = .systemFont(ofSize: 14)
        field.alignment = .center
        field.backgroundColor = .lightGray
        field.stringValue = "0"
        field.usesSingleLineMode = true
        
        if #available(OSX 10.13, *) {
            field.textColor = NSColor(named: "BackgroundColor")
        } else {
            field.textColor = NSColor(red:0.93, green:0.93, blue:0.93, alpha:1.00)
        }
        
        return field
    }()
    private let titleField: NSTextField = {
        let field = NSTextField()
        field.textColor = .lightGray
        field.alignment = .left
        field.drawsBackground = false
        field.stringValue = "test me please"
        return field
    }()
    private let button: NSButton = {
        let button = NSButton()
        button.title = ""
        button.wantsLayer = true
        button.layer?.backgroundColor = NSColor.clear.cgColor
        button.isBordered = false // This does the
        return button
    }()
    
    override init(frame frameRect: NSRect) {
        super.init(frame: .zero)
        
        let stackView = NSStackView(views: [self.indexField, self.titleField])
        
        button.target = self
        button.action = #selector(buttonAction)
        stackView.distribution = .fillProportionally
        stackView.orientation  = .horizontal
        stackView.alignment    = .centerY
        stackView.spacing      = 10
        
        [indexField, titleField].forEach { (field) in
            field.isBezeled       = false
            field.isEditable      = false
            field.isSelectable    = false
        }
        
        self.addSubview(stackView)
        self.addSubview(button)
        stackView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        indexField.snp.makeConstraints { (make) in
            make.height.width.equalTo(indexFieldSize)
        }
        button.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
    init(step: SetupStep = .one, title: String = "") {
        self.init()
        self.step = step
        self.title = title
        
        self.indexField.stringValue = String(format: "%i", self.step.rawValue+1)
        self.titleField.stringValue = self.title
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func layout() {
        super.layout()
        
        self.indexField.layer?.cornerRadius = indexFieldSize/2.0
        self.indexField.layer?.masksToBounds = true
    }
    @objc private func buttonAction() {
        guard isActionEnabled == true, let target = self.target, let action = self.action else {
            return
        }
        let _ = target.perform(action, with: self)
    }
}

class SetupViewController: NSViewController {
    static let intrinsicContentSize: NSSize  = NSSize(width: 600, height: 500)
    
    private var stepTimer: Timer?
    private var accessibilityTimer: Timer?
    private var hasStarted: Bool = false {
        didSet {
            self.startButton.isHidden = self.hasStarted
            self.waitingField.isHidden = !self.hasStarted
            
            if self.hasStarted {
                self.waitingIndicator.startAnimation(nil)
            }
            else {
                self.waitingIndicator.stopAnimation(nil)
            }
        }
    }
    private var currentStep: SetupStep = .one {
        didSet {
            [stepOneButton, stepTwoButton, stepThreeButton].forEach { (button) in
                button.isEnabled = button.step == self.currentStep
            }
            instructionalImageView.image = self.image(for: self.currentStep)
        }
    }
    private let startButton = NSButton()
    private let instructionalImageView = NSImageView()
    private let stepOneButton = SetupStepButton(step: .one, title: "Click Start Button")
    private let stepTwoButton = SetupStepButton(step: .two, title: "Unlock System Preferences")
    private let stepThreeButton = SetupStepButton(step: .three, title: "Select Notification Shortcuts")
    private let waitingField: NSTextField = {
        let field = NSTextField()
        field.stringValue = "Waiting..."
        field.isHidden = true
        return field
    }()
    private let waitingIndicator: NSProgressIndicator = {
        let indicator = NSProgressIndicator()
        indicator.isDisplayedWhenStopped = false
        indicator.stopAnimation(nil)
        indicator.style = .spinning
        return indicator
    }()
    
    override func loadView() {
        self.view = NSView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Initialize Variables
        let imageView        = NSImageView(frame: .zero)
        let descriptionField = NSTextField(frame: .zero)
        let descriptionString: NSAttributedString = {
            let name = NSAttributedString(string: "NotificationShortcuts",
                                          attributes: [NSAttributedString.Key.font: NSFont.boldSystemFont(ofSize: 14)])
            
            let value = NSAttributedString(string: " allows you to respond to notifications using keyboard shortcuts.\n\nIn order to work, NotificationShortcuts needs you to enable Accessibility access. Follow the steps below to do it. 👇",
                                           attributes: [NSAttributedString.Key.font: NSFont.systemFont(ofSize: 14)])
            
            let string = NSMutableAttributedString()
            string.append(name)
            string.append(value)
            return string
        }()
        let buttonStackView = NSStackView(views: [stepOneButton, stepTwoButton, stepThreeButton])
        let waitingStackView = NSStackView(views: [self.waitingField, self.waitingIndicator])
        
        //Set Group Properties
        [descriptionField, waitingField].forEach({ (field) in
            field.isBezeled       = false
            field.isEditable      = false
            field.isSelectable    = false
            field.drawsBackground = false
            field.alignment       = .center
            field.backgroundColor = NSColor.clear
        })
        [stepOneButton, stepTwoButton, stepThreeButton].forEach { (button) in
            button.action = #selector(stepButtonPressed(button:))
            button.target = self
        }
        
        //Set Individual Properties
        self.title                     = "Set Up"
        self.startButton.bezelStyle = .rounded
        self.startButton.title = "Start"
        self.startButton.target = self
        self.startButton.action = #selector(start)
        self.stepOneButton.isEnabled = true
        self.instructionalImageView.image = self.image(for: .one)
        imageView.image                = NSImage(named: "AppIcon")
        descriptionField.attributedStringValue = descriptionString
        buttonStackView.distribution = .gravityAreas
        buttonStackView.orientation  = .vertical
        buttonStackView.alignment    = .left
        buttonStackView.spacing      = 20
        waitingStackView.distribution = .gravityAreas
        waitingStackView.orientation  = .horizontal
        waitingStackView.alignment    = .centerY
        waitingStackView.spacing      = 10
        
        //Add Subviews
        self.view.addSubview(imageView)
        self.view.addSubview(descriptionField)
        self.view.addSubview(instructionalImageView)
        self.view.addSubview(buttonStackView)
        self.view.addSubview(startButton)
        self.view.addSubview(waitingStackView)
        
        //Set Constrains
        self.view.snp.makeConstraints { (make) in
            make.height.equalTo(SetupViewController.intrinsicContentSize.height)
            make.width.equalTo(SetupViewController.intrinsicContentSize.width)
        }
        imageView.snp.makeConstraints { (make) in
            make.top.equalTo(self.view).offset(20)
            make.left.equalTo(self.view).offset(30)
            make.height.width.equalTo(70)
        }
        descriptionField.snp.makeConstraints { (make) in
            make.top.equalTo(imageView)
            make.left.equalTo(imageView.snp.right).offset(15)
            make.right.equalToSuperview().offset(-30)
            make.height.equalTo(110)
        }
        buttonStackView.snp.makeConstraints { (make) in
            make.left.equalTo(imageView)
            make.centerY.equalTo(instructionalImageView)
            make.height.equalTo(130)
            make.width.equalTo(150)
        }
        instructionalImageView.snp.makeConstraints { (make) in
            make.left.equalTo(buttonStackView.snp.right).offset(20)
            make.top.equalTo(descriptionField.snp.bottom).offset(10)
            make.bottom.equalTo(startButton.snp.top).offset(-20)
            make.right.equalTo(descriptionField)
        }
        startButton.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview().offset(-20)
            make.centerX.equalToSuperview()
            make.height.equalTo(30)
            make.width.equalTo(150)
        }
        waitingStackView.snp.makeConstraints { (make) in
            make.centerX.centerY.equalTo(startButton)
            make.height.equalTo(25)
            make.width.greaterThanOrEqualTo(50)
        }
        waitingIndicator.snp.makeConstraints { (make) in
            make.height.width.equalTo(20)
        }
        
        //Start Cycle
        self.stepTimer = Timer.scheduledTimer(timeInterval: 2.5,
                                          target: self,
                                          selector: #selector(moveToNextStep),
                                          userInfo: nil,
                                          repeats: true)
        self.accessibilityTimer = Timer.scheduledTimer(timeInterval: 1,
                                                       target: self,
                                                       selector: #selector(checkAccessibilityStatus),
                                                       userInfo: nil,
                                                       repeats: true)
    }
    
    //MARK: Helpers
    private func image(for step: SetupStep) -> NSImage? {
        switch step {
        case .one:
            return NSImage(named: "StepOne")
        case .two:
            return NSImage(named: "StepTwo")
        case .three:
            return NSImage(named: "StepThree")
        }
    }
    
    //MARK: Actions
    @objc private func start() {
        guard let settingsURL = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility") else {
            return
        }
        
        NSWorkspace.shared.open(settingsURL)
        self.currentStep = .two
        self.hasStarted = true
    }
    
    @objc private func checkAccessibilityStatus() {
        if Setup.appHasAccessibilityAccess() {
            self.accessibilityTimer?.invalidate()
            self.stepTimer?.invalidate()
            self.accessibilityTimer = nil
            self.stepTimer = nil
            NotificationCenter.default.post(Setup.accessibilityAccessChangedNotification)
            self.view.window?.close()
        }
    }
    
    @objc private func stepButtonPressed(button: SetupStepButton) {
        if !self.hasStarted || button.step != .one {
            self.currentStep = button.step
        }
    }
    
    @objc private func moveToNextStep() {
        if let nextStep = SetupStep(rawValue: self.currentStep.rawValue+1) {
            self.currentStep = nextStep
        }
        else {
            self.currentStep = self.hasStarted ? .two : .one
        }
    }
}

