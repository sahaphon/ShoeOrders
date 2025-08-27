platform :ios, '13.0'

target 'ShoeOrder' do
  use_frameworks! :linkage => :static

  pod 'Alamofire', '~> 5.9'
  pod 'FirebaseCore'
  pod 'FirebaseAnalytics'
  pod 'FirebaseMessaging'
end

target 'ShoeOrderTests' do
  inherit! :search_paths
end

target 'ShoeOrderUITests' do
  inherit! :search_paths
end

post_install do |installer|
  installer.pods_project.targets.each do |t|
    t.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
    end
  end
end

