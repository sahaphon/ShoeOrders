platform :ios, '13.0'

target 'ShoeOrder' do
  use_frameworks!

  # ใช้ Alamofire รุ่นใหม่ (แนะนำ 5.9 ขึ้นไป)
  pod 'Alamofire', '~> 5.9'

  pod 'Firebase/Analytics'

end

target 'ShoeOrderTests' do
  inherit! :search_paths
end

target 'ShoeOrderUITests' do
  inherit! :search_paths
end

# บังคับ iOS deployment target ให้ทุก Pods
post_install do |installer|
  installer.pods_project.targets.each do |t|
    t.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
    end
  end
end

