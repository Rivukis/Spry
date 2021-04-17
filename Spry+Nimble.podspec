Pod::Spec.new do |spec|
  spec.name = 'Spry+Nimble'
  spec.version = '3.4.1'
  spec.summary = 'Nimble matcher for test expectations on Spyable objects.'

  spec.description = <<-DESC
    Spry+Nimble allows developers, used to working with Quick/Nimble, be able to test whether or not functions were called on objects in a helpful Nimble matcher. The haveReceived matcher contains rich failure messages when tests fail.
                       DESC

  spec.source       = { :git => "git@github.com:NikSativa/NCallback.git" }
  spec.homepage     = "https://github.com/NikSativa/NCallback"

  spec.license          = 'MIT'
  spec.author           = { "Nikita Konopelko" => "nik.sativa@gmail.com" }
  spec.social_media_url = "https://www.facebook.com/Nik.Sativa"

  spec.swift_version = '5.0'
  spec.ios.deployment_target = '10.0'
  spec.source_files = 'SourceNimble/*'

  spec.framework = 'XCTest'
  spec.dependency 'Nimble', '~> 9.0.0'
  spec.dependency 'Spry', '~> 3.4.0'

  spec.test_spec 'Tests' do |tests|
    # tests.requires_app_host = false

    tests.dependency 'Quick', '~> 3.1.2'

    tests.source_files = 'Tests/Specs/**/*.swift'
    tests.resources = ['Tests/Specs/**/*.{storyboard,xib,xcassets,json,imageset,png,strings,stringsdict}']
  end
end
