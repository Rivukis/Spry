Pod::Spec.new do |s|
  s.name             = 'Spry+Nimble'
  s.version          = '1.0'
  s.summary          = 'Nimble matcher for test expectations on Spyable objects.'

  s.description      = <<-DESC
    Spry+Nimble allows developers, used to working with Quick/Nimble, be able to test whether or not functions were called on objects in a helpful Nimble matcher. The haveReceived matcher contains rich failure messages when tests fail.
                       DESC

  s.homepage         = 'https://github.com/Rivukis/Spry'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Brian Radebaugh' => 'Rivukis@gmail.com' }
  s.source           = { :git => 'https://github.com/Rivukis/Spry.git', :tag => s.version.to_s }

  s.ios.deployment_target = '9.0'
  s.source_files = 'SpryExample/Spry+Nimble_Source/*'

  spec.dependency 'Nimble'
end