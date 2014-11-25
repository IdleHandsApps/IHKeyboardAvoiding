
An elegant solution for keeping any UIView visible when the keyboard is being shown

![alt demo](https://github.com/IdleHandsApps/IHKeyboardAvoiding/blob/gh-pages/IHKeyboardAvoidingDemo.gif)

## Description

IHKeyboardAvoiding will translate any UIView up when the keyboard is being shown, then return it when the keyboard is hidden.  

Two views are registered with IHKeyboardAvoiding, the ```avoidingView``` which is moved, and one or more ```targetViews``` which will trigger the avoiding.  If a ```targetView```'s frame will be intersected by the keyboard, then the ```avoidingView``` will move up just above the keyboard.

What sets IHKeyboardAvoiding apart from other keyboard avoiding solutions is that it doesn't require placing your content in a UIScrollView.  No scroll view is used. And it isn't restricted to keeping UITextFields visible, instead any UIView can be a target which will be kept visible

If Autolayout is used then the constraints are animated, otherwise a CGAffine translation is done.

## Supported Features:

* iPhone keyboard
* iPad docked keyboard
* iPad undocked keyboard
* iPad split keyboard
* landscape & protrait
* 3rd party keyboards
* autolayout
* traditional layout

## How to install

Add this to your CocoaPods Podfile.
```
pod 'IHKeyboardAvoiding'
```

## How to use:

To set the avoiding view
```objective-c
[IHKeyboardAvoiding setAvoidingView:(UIView *)avoidingView with:(UIView *)targetView];
```
To add another target
```objective-c
[IHKeyboardAvoiding addTarget:(UIView *)targetView];
```

Parameters   
```(UIView *)avoidingView```   The view to move above, usually the background view  
```(UIView *)targetView```      If a targetView's frame will be intersected by the keyboard, then the avoidingView will be moved so that the targetView is above the keyboard.
Usually you'll set the avoidingView and targetView as the same view. 

Optional methods    
```(BOOL)isKeyboardVisible```   A convenience method to check if the keyboard is visible  
```(void)setBuffer:(int)buffer``` The avoidingView will move if the keyboard is within [buffer] points of the targetView's frame.  Default buffer is 0  
```(void)setPadding:(int)buffer``` The padding to put between the keyboard and target view.  Default padding is 0
## IHKeyboardAvoiding vs UIScrollView solutions - Fight, fight!:
UIScrollView pros:
* They're quick n easy

IHKeyboardAvoiding pros:
* You dont have scrollviews littered throughout your app
* Having multiple scrollviews in your view heirarchy can cause problems
* When the keyboard hides, scrollviews dont always scroll back to their original position
* Scrollviews only scroll enough to keep the focused textfield visible
* IHKeyboardAvoiding provides control over which UIViews are visible when the keyboard appears

## Similar keyboard avoiding solutions:

https://github.com/michaeltyson/TPKeyboardAvoiding (UIScrollView based)  
https://github.com/kirpichenko/EKKeyboardAvoiding (UIScrollView based)  
https://github.com/robbdimitrov/RDVKeyboardAvoiding (UIScrollView based) 
https://github.com/hackiftekhar/IQKeyboardManager (looks interesting) 
https://github.com/danielamitay/DAKeyboardControl (looks interesting)

## Author

* Fraser Scott-Morrison (fraserscottmorrison@me.com)

It'd be great to hear about any cool apps that are using IHKeyboardAvoiding

## License 

Distributed under the MIT License

## Do To:

* Improve demo project

## Known Issue:

In iOS8 for iPad, when splitting/undocking the keyboard the notifications arent reliably sent by the OS meaning IHKeyboardAvoiding can be left in the wrong state
A radar has been filed http://openradar.appspot.com/18010127
