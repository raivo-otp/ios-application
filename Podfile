platform :ios, '11.0'

# Ignore warnings from external libraries
inhibit_all_warnings!

target 'Raivo' do
  use_frameworks!

  # Realm SQLite database handler that supports encryption
  # pod 'Realm', git: 'https://github.com/realm/realm-cocoa.git', branch: 'tg/xcode-11-b1', submodules: true, :inhibit_warnings => true
  # pod 'RealmSwift', git: 'https://github.com/realm/realm-cocoa.git', branch: 'tg/xcode-11-b1', submodules: true, :inhibit_warnings => true
  pod 'RealmSwift', '3.14.2', :inhibit_warnings => true
  
  # To encrypt sensitive data before being synced
  pod 'RNCryptor', '5.1.0', :inhibit_warnings => true
  
  # Allow access to Secure Enclave
  pod 'Valet', '3.2.5', :inhibit_warnings => true

  # A one time password URI parser (for if you scan QR codes)
  pod 'OneTimePassword', '3.1.5', :inhibit_warnings => true

  # Enables easy form creation for adding and editing passwords
  # pod 'Eureka', git: 'https://github.com/ykphuah/Eureka.git', branch: 'darkmode', :inhibit_warnings => true
  pod 'Eureka', '5.0.0', :inhibit_warnings => true
  pod 'ViewRow', '0.6', :inhibit_warnings => true
  
  # Retrieves, caches and displays images from the web (for issuer logos)
  pod 'SDWebImage', '5.0.6', :inhibit_warnings => true

  # Debug logging (only used in debug builds)
  pod 'SwiftyBeaver', '1.7.1', :inhibit_warnings => true

  # UI notification banners (e.g. for a notification if you copied an OTP)
  pod 'SwiftMessages', '7.0.0', :inhibit_warnings => true
  
  # Haptic feedback while e.g. entering PIN code or copying an OTP
  pod 'Haptica', '3.0.0', :inhibit_warnings => true
  
  # HTTP requests for custom issuer icons
  pod 'Alamofire', '4.8.1', :inhibit_warnings => true
  
  # Allows encrypted ZIP file creation for OTP exporting
  pod 'SSZipArchive', '2.2.2', :inhibit_warnings => true
  
  # QRCode generation for data export
  pod 'EFQRCode', '5.0.0', :inhibit_warnings => true
  
  # Swipable table view actions (for iOS < 11)
  pod 'SwipeCellKit', '2.6.0', :inhibit_warnings => true
  
  # More user friendly popover segues
  pod 'SPStorkController', '1.7.9', :inhibit_warnings => true
  
  # Nice banners
  pod 'SPAlert', '1.1.1', :inhibit_warnings => true

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
