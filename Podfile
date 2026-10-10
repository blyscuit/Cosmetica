platform :ios, '13.0'

use_frameworks!

target 'Cosmetica' do
  pod "Koloda"
  pod 'Spring', :git => 'https://github.com/MengTo/Spring.git', :branch => 'swift5'
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '15.0'
    end
  end

  `find Pods -regex 'Pods/pop.*\\.h' -print0 | xargs -0 sed -i '' 's/\$begin:math:text$\<\\$end:math:text$pop\\/\$begin:math:text$\.\*\\$end:math:text$\$begin:math:text$\>\\$end:math:text$/\\"\\2\\"/'`
end
