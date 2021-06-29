Pod::Spec.new do |spec|
  spec.name = 'NSpry'
  spec.version = '3.5.4'
  spec.summary = 'NSpry is spying and stubbing framework for Apple\'s Swift language.'

  spec.description = <<-DESC
    Spry allows developers to test a specific object without having to test dependency objects that the subject under test uses. Spyable allows a developer to check whether or not a function was called on an object with the correct arguments. Stubbable allows a developer to stub return values (or the entire implementation of a function) to ensure proper encapsulation during tests.
                       DESC

  spec.source       = { :git => "git@github.com:NikSativa/NSpry.git" }
  spec.homepage     = "https://github.com/NikSativa/NSpry"

  spec.license          = 'MIT'
  spec.author           = { "Nikita Konopelko" => "nik.sativa@gmail.com" }
  spec.social_media_url = "https://www.facebook.com/Nik.Sativa"

  spec.swift_version = '5.4'
  spec.ios.deployment_target = '10.0'

  spec.dependency 'Quick', '~> 4.0.0'
  spec.dependency 'Nimble', '~> 9.2.0'

  spec.source_files = 'Source/*'
end
