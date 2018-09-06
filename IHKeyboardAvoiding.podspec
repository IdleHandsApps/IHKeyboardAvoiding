Pod::Spec.new do |s|
  s.name             = "IHKeyboardAvoiding"
  s.version          = "4.3"
  s.summary          = "IHKeyboardAvoiding is an elegant solution for keeping any UIView visible when the keyboard is being shown"

  s.description      = <<-DESC
                       IHKeyboardAvoiding will translate any UIView up when the keyboard is being shown, then return it when the keyboard is hidden.

Two views are registered with IHKeyboardAvoiding, the avoidingView which is moved, and one or more targetViews which will trigger the avoiding. If a targetViews frame will be intersected by the keyboard, then the avoidingView will move up just above the keyboard.

What sets IHKeyboardAvoiding apart from other keyboard avoiding solutions is that it doesn’t require placing your content in a UIScrollView. No scroll view is used. And it isn’t restricted to keeping UITextFields visible, instead any UIView can be a target which will be kept visible

If Autolayout is used then the constraints are animated, otherwise a CGAffine translation is done
                       DESC

  s.homepage         = "https://github.com/IdleHandsApps/IHKeyboardAvoiding/"
  s.license          = { :type => "MIT" }

  s.author           = { "Fraser Scott-Morrison" => "fraserscottmorrison@me.com" }

  s.ios.deployment_target = "8.0"

  s.source           = { :git => "https://github.com/IdleHandsApps/IHKeyboardAvoiding.git", :tag => s.version.to_s }

  s.source_files = "Sources/*.swift"

  s.framework       = "UIKit"
  s.requires_arc    = true
end
