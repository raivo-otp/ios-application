# Security Policy

> Effective date: April 16, 2019

Raivo ("us", "we", or "our") operates the Raivo mobile application (the "Service").

The key words "must", "must not", "required", "shall", "shall not", "should", "should not", "recommended", "may" and "optional" in this document are to be interpreted as described in RFC 2119 [(Bradner, 1997)](https://www.ietf.org/rfc/rfc2119.txt).

The security of your data is important to us, but remember that no method of transmission over the Internet, or method of electronic storage is 100% secure. While we strive to use commercially acceptable means to protect your Personal Data, we cannot guarantee its absolute security.

This document outlines security procedures, policies and features for the Service.

  * [Reporting a vulnerability](#reporting-a-vulnerability)
  * [Vulnerability disclosure policy](#vulnerability-disclosure-policy)
  * [Data protection](#data-protection)

## Reporting a vulnerability

If you discover a security vulnerability, we would like to know about it so we can take steps to address it as quickly as possible. If you find a security vulnerability in a third-party module that is in use by Raivo, please also report the vulnerability to the person or team maintaining the module.

The Raivo HackerOne program (currently a private program) is used to manage security vulnerabilities in Raivo. If you have discoverd a vulnerability, please send a mail to the lead maintainer at `t{{dot}}gommers{{plus}}raivo{{at}}outlook{{dot}}com`. You will be invited to the HackerOne program to be able to report your security vulnerability.

The lead maintainer will acknowledge your report within 2 business days, and will send a more detailed response within 2 additional business days indicating the next steps in handling your report. After the initial reply to your report, the security team will endeavor to keep you informed of the progress towards a fix and full announcement, and may ask for additional information or guidance.

We strive to resolve all problems as quickly as possible, and we would like to play an active role in the ultimate publication on the problem after it is resolved.

## Vulnerability disclosure policy

When the security team receives a security vulnerability report, they will assign it to a primary handler. This person will coordinate the fix and release process, involving the following steps:

  * Confirm the vulnerability and determine the affected versions.
  * Audit the code to find any potential similar problems.
  * Prepare a fix for the upcoming release or a dedicated release. 
  * Publish the fix to the Apple App Store as soon as possible.

## Data protection

The Service stores personal data such OTP seeds and the information that is required to build the token. This data can be synchronized with third party companies to facilitate our Service ("Service Providers"), depending on what synchronized option you choose during the setup. We strive to encrypt this data in such a way that a Service Provider is never able to decrypt any of the data. 

### PIN code

A PIN code must be used to unlock the Service on your device. After entering a PIN code, a key will be derived using PBKDF2 based on a combination of your encryption key (that is stored in Secure Enclave) and the given PIN code. Using this derived key, the Service tries to decrypt the local database.

*Please note that the confidentiality, integrity and availability of the Service, including all your data, can be affected if one gains sufficient privileges (e.g. root privileges) on the device to read the local database from disk and the encryption key from Secure Enclave.*

### Synchronization

#### Offline (none)

If you choose "Offline (none)" as synchronization method, none of your data will be sent to a Service Provider. All the data will be stored in a local database on your device. This data is encrypted with a key that is derived using PBKDF2 based on a combination of your encryption key and PIN code. Your encryption key (that was defined during setup) is stored in Secure Enclave. Your PIN code is not stored on the device.

#### Apple iCloud

If you choose "Apple iCloud" as synchronization method, the statements of the "Offline (none)" synchronization method apply to the local database, with in addition that the data in the local database is sent to CloudKit (a database in Apple iCloud). The data that is sent to CloudKit is encrypted using your encryption key. Your encryption key (that was defined during setup) is stored in Secure Enclave. This allows you to have different PIN codes on different instances of the Service.
