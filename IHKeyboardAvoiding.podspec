Pod::Spec.new do |s|
  s.name             = 'IHKeyboardAvoiding'
  s.version          = '1.0.0'
  s.summary          = 'IHKeyboardAvoiding is a keyboard listener that will move any UIView up if the keyboard is being shown, and vice versa'
  s.homepage         = 'https://github.com/IdleHandsApps/KeyboardStateScroller/'
  s.description      = <<-DESC
                       Two views are registered with IHKeyboardAvoiding, a scrollingView and a targetView. If the targetView's frame will be intersected by the keyboard, then the scrollingView will be scrolled up the same distance and speed as the keyboard
                       DESC
  s.license          = 'MIT'
  s.author           = { 'Fraser Scott-Morrison' => 'fraserscottmorrison@me.com' }
  s.source           = { :git => 'https://github.com/IdleHandsApps/KeyboardStateScroller.git', :tag => s.version.to_s }
  s.platform     = :ios, '5.0'
  s.source_files = 'Classes/*.{h,m}'
  s.public_header_files = 'Classes/*.h'

  s.ios.deployment_target = '5.0'
  s.requires_arc = true
end
