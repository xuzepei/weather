# Uncomment the next line to define a global platform for your project
# platform :ios, '13.0'

#source 'https://github.com/CocoaPods/Specs.git'

target 'Weather' do
  use_frameworks!
  
  pod 'ReachabilitySwift','5.0.0'
  pod 'Toast','4.0.0'
  pod 'MBProgressHUD','1.2.0'
  pod 'Charts', '4.1.0'

end


post_install do |installer|
    installer.generated_projects.each do |project|
          project.targets.each do |target|
              target.build_configurations.each do |config|
                  config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
               end
          end
   end
end
