# Uncomment the next line to define a global platform for your project
platform :ios, '17.0'

target 'EcoVision' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for EcoVision
  pod 'GoogleMaps', '~> 8.3'
  pod 'GooglePlaces', '~> 8.3'

  target 'EcoVisionTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'EcoVisionUITests' do
    # Pods for testing
  end

end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '17.0'
    end
  end
end
