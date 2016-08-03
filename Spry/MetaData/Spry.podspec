Pod::Spec.new do |s|
    s.name                  = "Spry"
    s.version               = "0.1"
    s.summary               = "A Swift framework that adds a Nimble matcher, which enables the testing of whether functions have been called on stubs."
    s.description           = <<-DESC
                                Spry is a swift framework iOS, tvOS, and watchOS to allow developers to test whether objects are calling the correct functions on that object's dependencies. This aids in the development of decoupled classes.
                            DESC
    s.homepage              = "TODO add github page"
    s.license               = { :type => "MIT", :file => "LICENSE" }
    s.author                = { "Brian Radebaugh" => "Rivukis@gmail.com" }
    s.source                = { :git => "TODO add github's .git file", :tag => s.version }
    s.social_media_url      = "TODO maybe twitter page?"

    s.ios.deployment_target = "9.0"
    s.watchos.deployment_target = "2.0"
    s.tvos.deployment_target = "9.0"

    s.requires_arc = true

    s.source_files = "Sources/**/*.{h,swift}"

    s.dependency 'Nimble'
end