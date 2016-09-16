Pod::Spec.new do |s|

s.name         = "Qiscus"
s.version      = "0.5.4"
s.summary      = "Qiscus SDK for iOS"

s.description  = <<-DESC
Qiscus SDK for iOS contains Qiscus public Model.
DESC

s.homepage     = "https://qisc.us"

s.license      = "MIT"
s.author       = "Ahmad Athaullah"

s.source       = { :git => "https://github.com/a-athaullah/Qiscus.git", :tag => "#{s.version}" }


s.source_files  = "Qiscus/**/*.{swift}"
s.resource_bundles = {
    'Qiscus' => ['Qiscus/**/*.{storyboard,xib,xcassets,json,imageset,png}']
}

s.platform      = :ios, "8.3"

s.dependency 'Alamofire', '~> 3.0'
s.dependency 'AlamofireImage'
s.dependency 'PusherSwift', '2.0.1'
s.dependency 'RealmSwift'
s.dependency 'SwiftyJSON'
s.dependency 'ReachabilitySwift', '2.3.3'
s.dependency 'QToasterSwift'
s.dependency 'QAsyncImageView'
s.dependency 'SJProgressHUD'
s.dependency 'ImageViewer'

end