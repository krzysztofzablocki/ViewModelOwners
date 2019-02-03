Pod::Spec.new do |s|
 s.name = 'ViewModelOwners'
 s.version = '1.0.0'
 s.license = { :type => "MIT", :file => "LICENSE" }
 s.summary = 'Protocols that help make your MVVM setup more consistent'
 s.homepage = 'http://merowing.info'
 s.social_media_url = 'https://twitter.com/merowing_'
 s.authors = { "Krzysztof Zablocki" => "krzysztof.zablocki@pixle.pl" }
 s.source = { :git => "https://github.com/krzysztofzablocki/ViewModelOwners.git", :tag => "v"+s.version.to_s }
 s.platforms = { :ios => "9.0", :osx => "10.10", :tvos => "9.0", :watchos => "2.0" }
 s.requires_arc = true

 s.default_subspec = "Core"
 s.subspec "Core" do |ss|
     ss.source_files  = "Sources/**/*.swift"
     ss.framework  = "Foundation"
 end
end
