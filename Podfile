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
  
  # Disable resource copying scripts to avoid sandbox issues
  installer.pods_project.targets.each do |target|
    if target.name == 'Pods-EcoVision'
      target.build_phases.each do |phase|
        if phase.is_a?(Xcodeproj::Project::Object::PBXShellScriptBuildPhase)
          if phase.name && phase.name.include?('Copy Pods Resources')
            phase.run_only_for_deployment_postprocessing = true
          end
        end
      end
    end
  end
  
  # Remove resource copying scripts entirely
  installer.pods_project.targets.each do |target|
    if target.name == 'Pods-EcoVision'
      target.build_phases.delete_if do |phase|
        phase.is_a?(Xcodeproj::Project::Object::PBXShellScriptBuildPhase) &&
        phase.name && phase.name.include?('Copy Pods Resources')
      end
    end
  end
end
