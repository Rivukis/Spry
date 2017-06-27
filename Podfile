platform :ios, '9.0'

source 'https://github.com/CocoaPods/Specs.git'

use_frameworks!

target "SpryExample" do
    pod 'Quick'
    pod 'Nimble'

    abstract_target 'Tests' do
        inherit! :search_paths
        target "SpryExampleTests"
    end
end
