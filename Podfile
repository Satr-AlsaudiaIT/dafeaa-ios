# Uncomment the next line to define a global platform for your project
# platform :ios, '14.0'

target 'Dafeaa' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for Dafeaa

  pod 'IQKeyboardManagerSwift'
  pod 'SwiftyJSON'
  pod 'FirebaseAuth'
  pod 'FirebaseAnalytics'
  pod 'FirebaseCore'
  pod 'FirebaseMessaging'
  pod 'SDWebImageSwiftUI'
  pod 'Alamofire'
  pod 'Firebase'
  pod 'DSF_QRCode', '~> 24.0.0'
  
#  pod 'PhoneNumberKit'
pod "FlagPhoneNumber"
pod 'lottie-ios'
  target 'DafeaaTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'DafeaaUITests' do
    # Pods for testing
  end

end

post_install do |installer|
  
  installer.aggregate_targets.each do |target|
    target.xcconfigs.each do |variant, xcconfig|
      xcconfig_path = target.client_root + target.xcconfig_relative_path(variant)
      IO.write(xcconfig_path, IO.read(xcconfig_path).gsub("DT_TOOLCHAIN_DIR", "TOOLCHAIN_DIR"))
    end
  end
  
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
      if target.respond_to?(:product_type) and target.product_type == "com.apple.product-type.bundle"
        config.build_settings['CODE_SIGNING_ALLOWED'] = 'NO'
      end
      
      if config.base_configuration_reference.is_a? Xcodeproj::Project::Object::PBXFileReference
        xcconfig_path = config.base_configuration_reference.real_path
        IO.write(xcconfig_path, IO.read(xcconfig_path).gsub("DT_TOOLCHAIN_DIR", "TOOLCHAIN_DIR"))
      end
      
    end
  end
  
end
