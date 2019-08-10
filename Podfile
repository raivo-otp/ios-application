platform :ios, '11.0'

# Ignore warnings from external libraries
inhibit_all_warnings!

target 'Raivo' do
  use_frameworks!

  # Realm SQLite database handler that supports encryption
  # pod 'Realm', git: 'https://github.com/realm/realm-cocoa.git', branch: 'tg/xcode-11-b1', submodules: true
  # pod 'RealmSwift', git: 'https://github.com/realm/realm-cocoa.git', branch: 'tg/xcode-11-b1', submodules: true
  pod 'RealmSwift', '3.14.2'
  
  # To encrypt sensitive data before being synced
  pod 'RNCryptor', '5.1.0'
  
  # Allow access to Secure Enclave
  pod 'Valet', '3.2.5'

  # A one time password URI parser (for if you scan QR codes)
  pod 'OneTimePassword', '3.1.5'

  # Enables easy form creation for adding and editing passwords
  # pod 'Eureka', git: 'https://github.com/ykphuah/Eureka.git', branch: 'darkmode'
  pod 'Eureka', '5.0.0'
  pod 'ViewRow', '0.6'
  
  # Retrieves, caches and displays images from the web (for issuer logos)
  pod 'SDWebImage', '5.0.6'
  pod 'SDWebImageSVGCoder', '0.3.0'

  # Debug logging (only used in debug builds)
  pod 'SwiftyBeaver', '1.7.0'

  # UI notification banners (e.g. for a notification if you copied an OTP)
  pod 'SwiftMessages', '7.0.0'
  
  # Haptic feedback while e.g. entering PIN code or copying an OTP
  pod 'Haptica', '3.0.0'
  
  # HTTP requests for custom issuer icons
  pod 'Alamofire', '4.8.1'
  
  # Allows encrypted ZIP file creation for OTP exporting
  pod 'SSZipArchive', '2.2.2'
  
  # QRCode generation for data export
  pod 'EFQRCode', '5.0.0'
  
  # Swipable table view actions (for iOS < 11)
  pod 'SwipeCellKit', '2.6.0'
  
  # Easy view animations (like flikkering error messages)
  pod 'Spring', :git => 'https://github.com/MengTo/Spring.git'

end

# Specific dependencies compile using Swift 4.2
post_install do |installer|
  installer.pods_project.targets.each do |target|
    if ['Spring', 'SwiftyBeaver', 'Alamofire'].include? target.name
      target.build_configurations.each do |config|
        config.build_settings['SWIFT_VERSION'] = '4.2'
      end
    end
  end
end
