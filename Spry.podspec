Pod::Spec.new do |spec|
  spec.name = 'Spry'
  spec.version = '3.4.3'
  spec.summary = 'Spry is spying and stubbing framework for Apple\'s Swift language.'

  spec.description = <<-DESC
    Spry allows developers to test a specific object without having to test dependency objects that the subject under test uses. Spyable allows a developer to check whether or not a function was called on an object with the correct arguments. Stubbable allows a developer to stub return values (or the entire implementation of a function) to ensure proper encapsulation during tests.
                       DESC

  spec.source       = { :git => "git@github.com:NikSativa/NCallback.git" }
  spec.homepage     = "https://github.com/NikSativa/NCallback"

  spec.license          = 'MIT'
  spec.author           = { "Nikita Konopelko" => "nik.sativa@gmail.com" }
  spec.social_media_url = "https://www.facebook.com/Nik.Sativa"

  spec.swift_version = '5.4'
  spec.ios.deployment_target = '10.0'
  spec.source_files = 'Source/*'
end
