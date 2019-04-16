# Security Policy

Raivo ("us", "we", or "our") operates the Raivo mobile application (the "Service"), licensed under the [CC BY-NC 4.0](https://github.com/tijme/raivo/blob/master/LICENSE.md) license.

The security of your data is important to us, but remember that no method of transmission over the Internet, or method of electronic storage is 100% secure. While we strive to use commercially acceptable means to protect your Personal Data, we cannot guarantee its absolute security.

This document outlines security procedures, policies and features for the Service.

  * [Reporting a vulnerability](#reporting-a-vulnerability)
  * [Vulnerability Disclosure policy](#vulnerability-disclosure-policy)
  * [Data protection](#data-protection)

## Reporting a vulnerability

If you discover a security vulnerability, we would like to know about it so we can take steps to address it as quickly as possible. If you find a security vulnerability in a third-party module that is in use by Raivo, please also report the vulnerability to the person or team maintaining the module.

We are currently in the progress of creating a HackerOne page. In the meantime, please report your security vulnerability to the lead maintainer at `security [at] finnwea [dot] com`.

The lead maintainer will acknowledge your email within 2 business days, and will send a more detailed response within 2 additional business days indicating the next steps in handling your report. After the initial reply to your report, the security team will endeavor to keep you informed of the progress towards a fix and full announcement, and may ask for additional information or guidance.

We strive to resolve all problems as quickly as possible, and we would like to play an active role in the ultimate publication on the problem after it is resolved.

## Vulnerability Disclosure policy

When the security team receives a security vulnerability report, they will assign it to a primary handler. This person will coordinate the fix and release process, involving the following steps:

  * Confirm the vulnerability and determine the affected versions.
  * Audit the code to find any potential similar problems.
  * Prepare a fix for the upcoming release or a dedicated release. 
  * Publish the fix to the Apple App Store as soon as possible.

## Data protection

The service stores personal data such OTP seeds and the information that is required to build the token. This data can be synchronized with third party companies to facilitate our Service ("Service Providers"), depending on what synchronized option you choose during the setup. We strive to encrypt this data in such a way that a Service Provider is never able to decrypt any of the data. 

### Synchronization: Offline (none)

If you choose "Offline (none)" as synchronization method, none of your data will be sent to a Service Provider. All the data will be stored in a local database on your device. This data is AES-256 encrypted with a key that is derived using PBKDF2 based on a combination of your encryption key and pincode. Your encryption key (that was defined during setup) is stored in the iOS keychain. Your pincode is not stored on the device.

### Synchronization: Apple iCloud

If you choose "Apple iCloud" as synchronization method, the statements of the "Offline (none)" synchronization method apply to the local database, with in addition that the data in the local database is sent to CloudKit (a database in Apple iCloud). The data that is sent to CloudKit is AES-256 encrypted using your encryption key. Your encryption key (that was defined during setup) is stored in the iOS keychain.