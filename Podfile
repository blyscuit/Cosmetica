use_frameworks!

target 'Cosmetica' do
  pod "Koloda"
  pod 'Spring', :git => 'https://github.com/MengTo/Spring.git', :branch => 'swift5'
end

post_install do |installer|
  `find Pods -regex 'Pods/pop.*\\.h' -print0 | xargs -0 sed -i '' 's/\\(<\\)pop\\/\\(.*\\)\\(>\\)/\\"\\2\\"/'`
end
