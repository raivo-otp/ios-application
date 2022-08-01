# Security Policy

> Effective date: August 1, 2022

Raivo OTP ("us", "we", "our", "Raivo", "Tijme Gommers") operates the Raivo OTP related services (the "Services"). The Services include and are limited to the Source Format and Processed Format of [Raivo OTP for Apple iOS](https://github.com/raivo-otp/ios-application), [Raivo OTP for Apple MacOS](https://github.com/raivo-otp/macos-receiver), [Raivo OTP Issuer Icons](https://github.com/raivo-otp/issuer-icons), [Raivo OTP APNS Server](https://github.com/raivo-otp/apns-server) and [Raivo OTP Marketing Website](https://github.com/raivo-otp/marketing-website) (raivo-otp.com).

The security of your data is important to us, but remember that no method of transmission over the Internet, or method of electronic storage is 100% secure. While we strive to use commercially acceptable means to protect your Personal Data, we cannot guarantee its absolute security. This security policy (the "Security Policy") outlines security procedures, policies and features for the Services. Within this Security Policy, the key words "must", "must not", "required", "shall", "shall not", "should", "should not", "recommended", "may" and "optional" are to be interpreted as described in RFC 2119 [(Bradner, 1997)](https://www.ietf.org/rfc/rfc2119.txt).

## Table of Contents
  * [Reporting a vulnerability](#reporting-a-vulnerability)
  * [Vulnerability disclosure policy](#vulnerability-disclosure-policy)
  * [Data protection](#data-protection)

## Reporting a vulnerability

If you discover a security vulnerability, we would like to know about it so we can take steps to address it as quickly as possible. If you find a security vulnerability in a third-party ("Third Party") module that is in use by Raivo OTP, please also report the vulnerability to the person or team maintaining the module.

The [Raivo OTP HackerOne program](https://hackerone.com/raivo) is used to manage security vulnerabilities in Raivo OTP. If you have discoverd a security vulnerability, please report it via the HackerOne program. The lead maintainer will acknowledge your report within 5 business days, and will send a more detailed response within 5 additional business days indicating the next steps in handling your report. After the initial reply to your report, the security team will endeavor to keep you informed of the progress towards a fix and full announcement, and may ask for additional information or guidance.

We strive to resolve all problems as quickly as possible, and we would like to play an active role in the ultimate publication on the problem after it is resolved.

## Vulnerability disclosure policy

When the security team receives a security vulnerability report, they will assign it to a primary handler. This person will coordinate the fix and release process, involving the following steps:

  * Confirm the vulnerability and determine the affected versions.
  * Audit the code to find any potential similar problems.
  * Prepare a fix for the upcoming release or a dedicated release. 
  * Publish the fix to the Apple App Store as soon as possible.

## Data protection

The Service Raivo OTP for Apple iOS stores personal data such OTP seeds and the information that is required to build a one-time password. This data can be synchronised with Third Party companies to facilitate our Services ("Service Providers"), depending on what synchronised option you choose during the setup. We strive to encrypt this data in such a way that a Service Provider is never able to decrypt any of the data. 

### Raivo OTP for Apple iOS

#### PIN code

A PIN code must be used to unlock the Service Raivo OTP for Apple iOS on your Apple device (the "Device"). After entering a PIN code, a key will be derived using PBKDF2 based on a combination of your encryption key (that is stored in Secure Enclave) and the given PIN code. Using this derived key, the Service Raivo OTP for Apple iOS tries to decrypt the local database.

*Please note that the confidentiality, integrity and availability of the Service Raivo OTP for Apple iOS, including all your data, can be affected if one gains sufficient privileges (e.g. root privileges) on the Device to read the local database from disk and the encryption key from Secure Enclave.*

#### Synchronisation

##### Offline (none)

If you choose "Offline (none)" as synchronisation method, none of your data will be sent to a Service Provider. All the data will be stored in a local database on your Device. This data is encrypted with a key that is derived using PBKDF2 based on a combination of your encryption key and PIN code. Your encryption key (that was defined during setup) is stored in Secure Enclave. Your PIN code is not stored on the Device.

##### Apple iCloud

If you choose "Apple iCloud" as synchronisation method, the statements of the "Offline (none)" synchronisation method apply to the local database, with in addition that the data in the local database is sent to CloudKit (a database in Apple iCloud). The data that is sent to CloudKit is encrypted using your encryption key. Your encryption key (that was defined during setup) is stored in Secure Enclave. This allows you to have different PIN codes on different instances of the Service.

### Raivo OTP for Apple MacOS

The Service Raivo OTP for Apple MacOS does not store personal data such OTP seeds or the information that is required to build a one-time password. Upon installation, the Service Raivo OTP for Apple MacOS solely generates an encryption key that is used to decrypt one-time passwords received via Apple Push Notification Services.
