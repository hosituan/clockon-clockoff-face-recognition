platform :ios, '15.0'
use_frameworks!

# Face recognition comes from the FaceKit Swift package (added in the Xcode project).
target 'PersonRecognize' do
  pod 'Alamofire', '~> 5.9'
  pod 'SkyFloatingLabelTextField', '~> 3.8'
  pod 'IQKeyboardManagerSwift', '~> 6.5'
  pod 'Firebase/Database', '~> 11.0'
  pod 'Firebase/Storage', '~> 11.0'
  pod 'ProgressHUD', '~> 13.8'
  pod 'SDWebImage', '~> 5.19'
  pod 'RxSwift', '~> 6.7'
  pod 'RxCocoa', '~> 6.7'
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      # Old pod specs declare iOS 8/9 targets, which current Xcode no longer builds.
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '15.0'
    end
  end
end
