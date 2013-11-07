Pod::Spec.new do |s|
  s.name         = "WalterTrent"
  s.version      = "0.0.1"
  s.summary      = "WalterTrent is a lightweight ORM for SQLite in iOS."
  s.description  = <<-DESC
                   A longer description of WalterTrent in Markdown format.

                   * Think: Why did you write this? What is the focus? What does it do?
                   * CocoaPods will be using this to generate tags, and improve search results.
                   * Try to keep it short, snappy and to the point.
                   * Finally, don't worry about the indent, CocoaPods strips it!
                   DESC
  s.homepage     = "http://github.com/snooc/WalterTrent"
  s.license      = 'MIT (example)'
  s.author       = { "Cody Coons" => "cody@codycoons.com" }
  s.platform     = :ios, '7.0'
  s.source       = { :git => "http://EXAMPLE/WalterTrent.git", :tag => "0.0.1" }
  s.source_files = 'WalterTrent/**/*.{h,m}'
  s.requires_arc = true
  s.xcconfig     = { 'OTHER_CFLAGS' => '$(inherited) -DSQLITE_HAS_CODEC' }
  s.dependency 'SQLCipher'
end
