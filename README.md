<h1 align="center">Raivo</h1>
<p align="center">
    <a href="https://github.com/tijme/raivo/blob/master/LICENSE.md"><img src="https://raw.finnwea.com/shield/?firstText=License&secondText=CC%20BY-NC%204.0" /></a>
    <a href="https://itunes.apple.com/"><img src="https://raw.finnwea.com/shield/?firstText=Platform&secondText=iOS%20(10%20or%20higher)" /></a>
    <a href="https://github.com/tijme/raivo/releases"><img src="https://raw.finnwea.com/shield/?typeKey=SemverVersion&typeValue1=raivo&typeValue2=master&typeValue4=Beta"></a>
    <br/>
    <b>A native, lightweight and secure one-time & time-based password client built for iOS</b>
    <br/>
    <sup>Built by <a href="https://www.linkedin.com/in/tijme/">Tijme Gommers</a> – Donate via <a href="https://bunq.me/tijme/0/Raivo;%20a%20native,%20lightweight%20and%20secure%20one-time%20&%20time-based%20password%20client%20built%20for%20iOS">Bunq</a></sup>
    <br/>
</p>

<p align="center">
    <img src="https://github.com/tijme/raivo/raw/master/.github/preview_left.png" width="280">
    <img src="https://github.com/tijme/raivo/raw/master/.github/preview_middle.png" width="280">
    <img src="https://github.com/tijme/raivo/raw/master/.github/preview_right.png" width="280">
</p>

**Table of Contents:**
* [Features](#features)
* [Contributing](#contributing)
* [Issues](#issues)
* [Security](#security)
* [License](#license)

## Features

* Backup/sync OTPs to iCloud automagically
* Scan a QR code or add an OTP manually
* Show the current and previous token
* Search using powerful search capabilities
* It's fast (native, built in Swift v4.2)
* It's secure (developed by a security specialist)

## Upcoming features:

* Custom issuer logos
* Multilingual support
* HOTP (counter-based token)
* TouchID unlock
* Scan OTP seeds from shared password managers
* Backup/sync OTPs to other third-party services

## Contributing

#### Cloning the project

You can clone the project using GIT. The master branch always contains the latest stable code. The `develop` branch always contains the latest changes (but is unstable).

`git clone git@github.com:tijme/raivo.git`

#### CocoaPods

CocoaPods is a dependency manager for Swift and Objective-C Cocoa projects. Install it using the instructions on their website [www.cocoapods.org](https://cocoapods.org/). Afterwards, navigate to the project root and install all the pods.

`pod install`

#### Making changes

Make sure you open **Raivo.xcworkspace** instead of the default project file. Opening Raivo.xcworkspace will make sure Xcode loads all the pods.

#### Compiling

You can now compile the app for every iOS 11 device using Xcode!

## Issues

Issues or new features can be reported via the [issue tracker](https://github.com/tijme/raivo/issues). Please make sure your issue or feature has not yet been reported by anyone else before submitting a new one.

## Security

If you discover a security vulnerability, we would like to know about it so we can take steps to address it as quickly as possible. Please contact us at `security[at]finnwea[dot]com`.

## License

Raivo is non-commercial open-sourced software licensed under the [CC BY-NC 4.0](https://github.com/tijme/raivo/blob/master/LICENSE.md) license.
