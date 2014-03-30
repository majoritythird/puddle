platform :ios, :deployment_target => '7.0'

xcodeproj 'Puddle.xcodeproj'

inhibit_all_warnings!

pod 'BlocksKit'

# Remove 64-bit build architecture from Pods targets
post_install do |installer|
  installer.project.targets.each do |target|
    target.build_configurations.each do |configuration|
      target.build_settings(configuration.name)['ARCHS'] = '$(ARCHS_STANDARD_32_BIT)'
    end
  end
end
