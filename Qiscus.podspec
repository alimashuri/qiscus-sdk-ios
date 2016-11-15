Pod::Spec.new do |s|

s.name         = "Qiscus"
s.version      = "2.0.8"
s.summary      = "Qiscus SDK for iOS"

s.description  = <<-DESC
Qiscus SDK for iOS contains Qiscus public Model.
DESC

s.homepage     = "https://qisc.us"

s.license      = "MIT"
s.author       = "Ahmad Athaullah"

s.source       = { :git => "https://github.com/qiscus/qiscus-sdk-ios.git", :tag => "#{s.version}" }


s.source_files  = "Qiscus/**/*.{swift}"
s.resource_bundles = {
    'Qiscus' => ['Qiscus/**/*.{storyboard,xib,xcassets,json,imageset,png}']
}

s.platform      = :ios, "9.0"

s.dependency 'Alamofire', '~> 4.0'
s.dependency 'AlamofireImage'
s.dependency 'PusherSwift'
s.dependency 'RealmSwift'
s.dependency 'SwiftyJSON'
s.dependency 'ImageViewer'

end
