# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'AxRide' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for AxRide
  pod 'IHKeyboardAvoiding'
  
  pod 'KMPlaceholderTextView', '~> 1.3.0'
  pod 'Cosmos', '~> 16.0'
  
  pod 'GoogleMaps'
  pod 'GooglePlaces'
  pod 'GooglePlacePicker'
  
  pod 'Firebase/Core'
  pod 'Firebase/Auth'
  pod 'Firebase/Database'
  pod 'Firebase/Storage'
  pod 'Firebase/Messaging'
  
  pod 'SDWebImage'
  pod 'SVProgressHUD'
  pod 'ReachabilitySwift'
  
  pod 'FBSDKLoginKit'
  pod 'GoogleSignIn'
  pod 'EmptyDataSet-Swift', '~> 4.0.5'

  target 'AxRideTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'AxRideUITests' do
    inherit! :search_paths
    # Pods for testing
  end
  
  # Workaround for Cocoapods issue #7606
  post_install do |installer|
      installer.pods_project.build_configurations.each do |config|
          config.build_settings.delete('CODE_SIGNING_ALLOWED')
          config.build_settings.delete('CODE_SIGNING_REQUIRED')
      end
  end

end
