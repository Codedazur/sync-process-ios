#
# Be sure to run `pod lib lint CDASyncService.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#
# Any lines starting with a # are optional, but encouraged
#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "CDASyncService"
  s.version          = "0.0.4"
  s.summary          = "Framework for Sync Processes"
  s.description      = <<-DESC
                       Base Framework to use for syncing a large amount of data into an app
                       DESC
  s.homepage         = "https://github.com/Codedazur/sync-process-ios"
  # s.screenshots     = "www.example.com/screenshots_1", "www.example.com/screenshots_2"
  s.license          = 'MIT'
  s.author           = { "tamarabernad" => "tamara@codedazur.es" }
  s.source           = { :git => "https://github.com/Codedazur/sync-process-ios.git", :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.platform     = :ios, '7.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes/**/*'
 # s.resource_bundles = {
  #  'CDASyncService' => 'Pod/Classes/Utils/BackgroundTransfer/Model/background-download.xcdatamodeld'
  #}
  s.resources = 'Pod/Classes/Utils/BackgroundTransfer/Model/background-download.xcdatamodeld'

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  s.dependency 'AFNetworking', '~> 3.1'
  s.dependency 'RestKit/CoreData'
  s.dependency 'SSZipArchive', '~> 1.1'
end
