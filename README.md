![Header](https://github.com/Frostbitee08/NotificationShortcuts/blob/master/.readme-resources/banner.png)

# NotificationShortcuts
NotificationShortcuts is a macOS app that allows users to respond to notifications using keyboard shortcuts.

[![Swift Version][swift-image]][swift-url]

## Installation
Download the latest version of NotificationShortcuts [here](https://delpriore-appcasts.s3-us-west-1.amazonaws.com/NotificationShortcuts+0.9.3.dmg).

## Usage
NotificationShortcuts offers three ways to respond to a notification.

| Action  | Description |
| ------- |-------------|
| Reply   | Activates the primary button associated with the notification. For example, notifications from the Messages app will drop down a text field where you can type a response. |
| Open    | The equivalent to clicking the notification. It will launch the corresponding notification and navigate to the content the notification delivered. |
| Dismiss | Closes all of the open notifications. |


Keyboard shortcuts for these actions are accessible from the preferences window, which users can open from the menu bar icon. 

![](https://github.com/Frostbitee08/NotificationShortcuts/blob/master/.readme-resources/preferences.png)

## Xcode Setup
### Requirements
* [Carthage](https://github.com/Carthage/Carthage): [Installation Instructions](https://github.com/Carthage/Carthage#installing-carthage)
* [Xcode 11.3+](https://developer.apple.com/xcode/): [Installation Instructions](https://apps.apple.com/us/app/xcode/id497799835?mt=12)

### Build
These instructions document how to clone and set up a local copy of NotificationShortcuts.

1. Clone the repo
``` Bash
git clone https://github.com/Frostbitee08/NotificationShortcuts
```

2. Navigate to the project's directory
``` Bash
cd /path-to-NotificationShortcuts/
```

3. Install dependenecies
``` Bash
carthage update --platform macOS
```

4. Open the project
``` Bash
open NotificationShortcuts.xcworkspace
```

5. Press ⌘-B to build the project, it should compile successfully

[swift-image]:https://img.shields.io/badge/swift-5.0-blue.svg
[swift-url]: https://swift.org/
