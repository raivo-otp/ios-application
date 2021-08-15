platform :ios, '14.1'

# Ignore warnings from external libraries
inhibit_all_warnings!

# Application
target 'Raivo' do
  use_frameworks!

  # Realm SQLite database handler that supports encryption
  pod 'RealmSwift', '5.4.7'
  
  # To encrypt sensitive data before being synced
  pod 'RNCryptor', '5.1.0'
  
  # Allow access to Secure Enclave
  pod 'Valet', '3.2.8'

  # A one time password URI parser (for if you scan QR codes)
  pod 'OneTimePassword', '3.2.0'

  # Enables easy form creation for adding and editing passwords
  pod 'Eureka', '5.3.2'
  pod 'ViewRow', '0.8'
  
  # Retrieves, caches and displays images from the web (for issuer logos)
  pod 'SDWebImage', '5.10.2'

  # Debug logging (only used in debug builds)
  pod 'SwiftyBeaver', '1.9.3'

  # Haptic feedback while e.g. entering PIN code or copying an OTP
  pod 'Haptica', '3.0.2'
  
  # HTTP requests for custom issuer icons
  pod 'Alamofire', '4.9.1'
  
  # Allows encrypted ZIP file creation for OTP exporting
  pod 'SSZipArchive', '2.2.3'
  
  # QRCode generation for data export
  pod 'EFQRCode', '6.0.0'
  
  # Swipable table view actions (for iOS < 11)
  pod 'SwipeCellKit', '2.7.1'

  # UI notification banners (e.g. for a notification if you copied an OTP)
  pod 'SPAlert', '2.1.4'
  
  # More user friendly popover segues
  pod 'SPStorkController', '1.8.4'
  
  # Zalando's monkey testing client
  pod 'SwiftMonkeyPaws', '2.2.0'

  # HTML utilities (encoding/decoding)
  pod 'HTMLString', '6.0.1'
  
end

# Tests
target 'RaivoUITests' do
    pod 'SwiftMonkey', '2.2.0'
end

# Specific dependencies compile using Swift 4.2
post_install do |installer|
  installer.pods_project.targets.each do |target|
    if ['Alamofire'].include? target.name
      target.build_configurations.each do |config|
        config.build_settings['SWIFT_VERSION'] = '4.2'
      end
    end
  end
end
