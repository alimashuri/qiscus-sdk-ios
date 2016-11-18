Pod::Spec.new do |s|

s.name         = "Qiscus"
s.version      = "0.6"
s.summary      = "Qiscus SDK for iOS"

s.description  = <<-DESC
Qiscus Chat SDK for iOS. Instant chat on your app.
DESC

s.homepage     = "https://qisc.us"

s.license      = "MIT"
s.author       = "Qiscus Pte Ltd"

s.source       = { :git => "https://github.com/qiscus/qiscus-sdk-ios.git", :branch => "Swift2.2", :tag => "#{s.version}" }

s.source_files  = "Qiscus/**/*.{swift}"
s.resource_bundles = {
    'Qiscus' => ['Qiscus/**/*.{storyboard,xib,xcassets,json,imageset,png}']
}

s.platform      = :ios, "8.3"

s.dependency 'Alamofire', '~> 3.4.0'
s.dependency 'AlamofireImage', '~> 2.4.0'
s.dependency 'PusherSwift', '~> 2.0.0'
s.dependency 'RealmSwift', '~> 1.0.0'
s.dependency 'SwiftyJSON', '~> 2.3.0'
s.dependency 'ReachabilitySwift', '2.3.3'
s.dependency 'QToasterSwift', '0.2.1'
s.dependency 'QAsyncImageView', '0.1.1'
s.dependency 'SJProgressHUD', '0.0.3'
s.dependency 'ImageViewer', '2.1'

end
