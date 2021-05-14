Pod::Spec.new do |s|
  s.name             = 'Legible'
  s.version          = '0.1.0'
  s.summary          = 'Quick and Nimble Behaviors and Helpers'
  s.description      = <<-DESC
Set of Quick and Nimble Behaviors and Helpers
to make spec more readable
                       DESC

  s.homepage         = 'https://github.com/sparta-science/Legible'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'sparta-science' => 'www.spartascience.com' }
  s.source           = {
      :git => 'https://github.com/sparta-science/Legible.git',
      :tag => s.version.to_s
  }

  s.ios.deployment_target = "9.0"
  s.osx.deployment_target = "10.10"
  s.tvos.deployment_target = "9.0"
  s.source_files = 'Legible/Classes/**/*'
  s.requires_arc = true
  s.weak_framework = 'XCTest'
  s.cocoapods_version = '>= 1.4.0'
  s.swift_versions = ['5.0']
  s.dependency 'Nimble', '~> 9.0'
  s.dependency 'Quick', '~> 4.0'
end
