Pod::Spec.new do |s|
  s.name             = 'Spry'
  s.version          = '2.1'
  s.summary          = 'Spry is spying and stubbing framework for Apple\'s Swift language.'

  s.description      = <<-DESC
    Spry allows developers to test a specific object without having to test dependency objects that the subject under test uses. Spyable allows a developer to check whether or not a function was called on an object with the correct arguments. Stubbable allows a developer to stub return values (or the entire implementation of a function) to ensure proper encapsulation during tests.
                       DESC

  s.homepage         = 'https://github.com/Rivukis/Spry'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Brian Radebaugh' => 'Rivukis@gmail.com' }
  s.source           = { :git => 'https://github.com/Rivukis/Spry.git', :tag => s.version.to_s }

  s.ios.deployment_target = '9.0'
  s.source_files = 'Example/Source/*'
end
