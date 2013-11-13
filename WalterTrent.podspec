Pod::Spec.new do |s|
  s.name         = "WalterTrent"
  s.version      = "0.1.0"
  s.summary      = "WalterTrent is a lightweight utility library for SQLCipher/SQLite in iOS."
  s.description  = <<-DESC
                    Walter,Trent is a lightweight utility libary for SQLCipher based applications.
                   DESC
  s.homepage     = "http://github.com/snooc/WalterTrent"
  s.license      = 'MIT (example)'
  s.author       = { "Cody Coons" => "cody@codycoons.com" }
  s.platform     = :ios, '7.0'
  s.source       = { :git => "https://github.com/snooc/WalterTrent", :tag => "v0.1.0" }
  s.source_files = 'WalterTrent/**/*.{h,m}'
  s.requires_arc = true
  s.xcconfig     = { 'OTHER_CFLAGS' => '$(inherited) -DSQLITE_HAS_CODEC' }
  s.dependency 'SQLCipher'
end
