
Pod::Spec.new do |spec|

  spec.name     = 'CheckoutBazinga'
  spec.version  = '0.5.0'
  spec.license  = 'MIT'
  spec.summary  = 'A delightful Payments UI framework to be helpful with Bambora related development.'
  spec.homepage = 'http://developer.na.bambora.com'
  spec.authors  = 'Sven M. Resch'
  spec.source   = { :git => 'https://github.com/bazingatechnologies/na-ios-checkout.git',
  					:tag => spec.version.to_s }
  spec.platform     = :ios, '8.2'
  spec.requires_arc = true

  spec.source_files = 'Checkout/Classes/**/*'
  spec.resources    = 'Checkout/Resources/**/*'

  spec.framework = 'UIKit'

end

