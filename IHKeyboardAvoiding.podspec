Pod::Spec.new do |s|
  s.name             = 'IHKeyboardAvoiding'
  s.version          = '1.0.1'
  s.summary          = 'IHKeyboardAvoiding is an elegant solution for keeping any UIView visible when the keyboard is being shown'
  s.homepage         = 'https://github.com/IdleHandsApps/IHKeyboardAvoiding/'
  s.description      = <<-DESC
                       IHKeyboardAvoiding will translate any UIView up when the keyboard is being shown, then return it when the keyboard is hidden.

Two views are registered with IHKeyboardAvoiding, the 'avoiding' UIView which is moved, and one or more 'target' UIViews which will be kept visible above the keyboard. If a target view's frame will be intersected by the keyboard, then the avoiding view will move up, keeping the target view just above the keyboard.

What sets IHKeyboardAvoiding apart from other keyboard avoiding solutions is that it doesn't require placing your content in a UIScrollView. No scroll view is used. And it isn't restricted to keeping UITextFields visible, instead any UIView can be a target which will be kept visible

If Autolayout is used then the constraints are animated, otherwise a CGAffine translation is done
                       DESC
  s.license          = 'MIT'
  s.author           = { 'Fraser Scott-Morrison' => 'fraserscottmorrison@me.com' }
  s.source           = { :git => 'https://github.com/IdleHandsApps/IHKeyboardAvoiding.git', :tag => s.version.to_s }
  s.platform     = :ios, '5.0'
  s.source_files = 'Classes/*.{h,m}'
  s.public_header_files = 'Classes/*.h'

  s.ios.deployment_target = '5.0'
  s.requires_arc = true
end
