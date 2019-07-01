//
//  KeyboardAvoiding.swift
//  Pods
//
//  Created by Fraser on 20/12/16.
//
//

import UIKit

@objc public enum KeyboardAvoidingMode: Int {
    case maximum
    case minimum
    case minimumDelayed
}

@objc public class KeyboardAvoiding: NSObject {
    
    private static var minimumAnimationDuration: CGFloat = 0.0
    private static var lastNotification: Foundation.Notification?
    private static var updatedConstraints = [NSLayoutConstraint]()
    private static var updatedConstraintConstants = [CGFloat]()
    private static var avoidingViewUsesAutoLayout = false
    private static var triggerViews = [UIView]()
    private static var showingAnimationCount = 0
    
    public private(set) static var isKeyboardVisible = false
    public static var buffer: CGFloat = 0.0
    public static var paddingForCurrentAvoidingView: CGFloat = 0.0
    @objc public static var padding: CGFloat = 0.0 {
        willSet {
            if self.paddingForCurrentAvoidingView == newValue {
                // if paddingCurrent has been set explicitly, dont reset it
                self.paddingForCurrentAvoidingView = newValue
            }
        }
    }
    public static var keyboardAvoidingMode = KeyboardAvoidingMode.minimum
    @objc public static var avoidingBlock: ((Bool, CGFloat, CGFloat, UIView.AnimationOptions)->Void)? {
        willSet {
            self.initialise()
        }
        didSet {
            if self.triggerViews.count == 0 && self.avoidingBlock != nil {
                self.triggerViews.append(UIView())
            }
        }
    }
    private static var _avoidingView: UIView?
    @objc public static var avoidingView: UIView? {
        get {
            return _avoidingView
        }
        set {
            self.setAvoidingView(newValue, withOptionalTriggerView: newValue)
        }
    }
    
    class func didChange(_ notification: Foundation.Notification) {
        var isKeyBoardShowing = false
        // isKeyBoardShowing and is it merged and docked.
        
        let isPortrait =  UIApplication.shared.statusBarOrientation.isPortrait
        // get the keyboard & window frames
        
        let keyboardFrame = notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! CGRect
        // keyboardHeightDiff used when user is switching between different keyboards that have different heights
        var keyboardFrameBegin = notification.userInfo![UIResponder.keyboardFrameBeginUserInfoKey] as! CGRect
        
        // hack for bug in iOS 11.2
        let keyboardFrameEnd = notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! CGRect
        if keyboardFrameEnd.size.height > keyboardFrameBegin.size.height {
            keyboardFrameBegin = CGRect(x: keyboardFrameBegin.origin.x, y: keyboardFrameBegin.origin.y, width: keyboardFrameBegin.size.width, height: keyboardFrameEnd.size.height)
        }
        
        var keyboardHeightDiff:CGFloat = 0.0
        if keyboardFrameBegin.size.height > 0 {
            keyboardHeightDiff = keyboardFrameBegin.size.height - keyboardFrame.size.height
        }
        let screenSize = UIScreen.main.bounds.size
        let animationCurve = notification.userInfo![UIResponder.keyboardAnimationCurveUserInfoKey] as! Int
        let animationOptions = animationCurve << 16
        // if split keyboard is being dragged, then skip notification
        
        if keyboardFrame.size.height == 0 && (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad) {
            if isPortrait && keyboardFrameBegin.origin.y + keyboardFrameBegin.size.height == screenSize.height {
                return
            }
            else if !isPortrait && keyboardFrameBegin.origin.x + keyboardFrameBegin.size.width == screenSize.width {
                return
            }
        }
        // calculate if we are to move up the avoiding view
        if !keyboardFrame.isEmpty && (keyboardFrame.origin.y == 0 || (keyboardFrame.origin.y + keyboardFrame.size.height == screenSize.height)) {
            isKeyBoardShowing = true
            self.lastNotification = notification
        }
        
        // get animation duration
        var animationDuration = notification.userInfo![UIResponder.keyboardAnimationDurationUserInfoKey] as! CGFloat
        if animationDuration == 0 {
            // custom keyboards often dont animate, its too clanky so have to manually set this
            animationDuration = 0.1
        }
        if isKeyBoardShowing {
            self.showingAnimationCount = 0
            for triggerView in self.triggerViews {
                
                //showing and docked
                var diff: CGFloat = 0.0
                if keyboardHeightDiff != 0 {
                    // if keyboard height is changing and avoidingView is currently moved
                    diff = keyboardHeightDiff
                }
                else {
                    let originInWindow = triggerView.convert(triggerView.bounds.origin, to: nil)
                    switch UIApplication.shared.statusBarOrientation {
                    case .portrait, .landscapeLeft:
                        diff = keyboardFrame.origin.y
                        diff = diff - (originInWindow.y + triggerView.frame.size.height)
                        break
                    case .portraitUpsideDown, .landscapeRight:
                        diff = screenSize.height - keyboardFrame.size.height
                        diff = diff - (originInWindow.y + triggerView.frame.size.height)
                        break
                    default:
                        break
                    }
                }
                var displacement = (isPortrait ? -keyboardFrame.size.height : -keyboardFrame.size.width)
                if diff < self.buffer || keyboardHeightDiff != 0 {
                    var delay: CGFloat = 0.0
                    switch self.keyboardAvoidingMode {
                    case .maximum:
                        self.minimumAnimationDuration = animationDuration
                        break
                    case .minimumDelayed:
                        let minimumDisplacement = max(displacement, diff)
                        self.minimumAnimationDuration = animationDuration * (minimumDisplacement / displacement)
                        displacement = minimumDisplacement - self.paddingForCurrentAvoidingView
                        delay = (animationDuration - self.minimumAnimationDuration)
                        animationDuration = self.minimumAnimationDuration
                        break
                    default:
                        let minimumDisplacement = max(displacement, diff)
                        displacement = minimumDisplacement - (keyboardHeightDiff == 0 ? self.paddingForCurrentAvoidingView : 0)
                        
                    }
                    
                    if self.avoidingView != nil && self.avoidingView!.superview != nil {
                        if self.avoidingViewUsesAutoLayout {
                            // if view uses constraints
                            var hasFoundFirstConstraint = false
                            for constraint: NSLayoutConstraint in self.avoidingView!.superview!.constraints {
                                
                                if let secondItem = constraint.secondItem as? NSObject, secondItem == self.avoidingView! && (constraint.secondAttribute == .centerY || constraint.secondAttribute == .top || constraint.secondAttribute == .bottom) {
                                    if !self.updatedConstraints.contains(constraint) {
                                        self.updatedConstraints.append(constraint)
                                        self.updatedConstraintConstants.append(constraint.constant)
                                    }
                                    constraint.constant -= displacement
                                    hasFoundFirstConstraint = true
                                }
                            }
                            
                            if !hasFoundFirstConstraint {
                                // if the constraint.secondItem wasn't found, sometimes its the constraint.firstItem that needs to be updated
                                for constraint: NSLayoutConstraint in self.avoidingView!.superview!.constraints {
                                    if constraint.firstItem as! NSObject == self.avoidingView! && (constraint.firstAttribute == .centerY || constraint.firstAttribute == .top || constraint.firstAttribute == .bottom) {
                                        if !self.updatedConstraints.contains(constraint) {
                                            self.updatedConstraints.append(constraint)
                                            self.updatedConstraintConstants.append(constraint.constant)
                                        }
                                        constraint.constant += displacement
                                    }
                                }
                            }
                            self.avoidingView!.superview!.setNeedsUpdateConstraints()
                        }
                        self.showingAnimationCount += 1
                        
                        UIView.animate(withDuration: TimeInterval(animationDuration), delay: TimeInterval(delay), options: UIView.AnimationOptions(rawValue: UInt(animationOptions)), animations: {() -> Void in
                            if self.avoidingViewUsesAutoLayout {
                                self.avoidingView!.superview!.layoutIfNeeded()
                                // to animate constraint changes
                            }
                            else {
                                var transform = self.avoidingView!.transform
                                transform = transform.translatedBy(x: 0, y: displacement)
                                self.avoidingView!.transform = transform
                            }
                        }, completion: { _ in
                            self.showingAnimationCount -= 1
                        })
                    }
                }
                if self.avoidingBlock != nil {
                    self.avoidingBlock!(isKeyBoardShowing, animationDuration, displacement, UIView.AnimationOptions(rawValue: UInt(animationOptions)))
                }
            }
            
        }
        else if self.isKeyboardVisible {
            // hiding, undocking or splitting
            switch self.keyboardAvoidingMode {
            case .maximum:
                break
            case .minimumDelayed:
                animationDuration = self.minimumAnimationDuration
                break
            default:
                break
            }
            
            // restore state
            if self.avoidingView != nil && self.avoidingView!.superview != nil {
                if self.avoidingViewUsesAutoLayout {
                    // if view uses constrains
                    for (index, updatedConstraint) in self.updatedConstraints.enumerated() {
                        let updatedConstraintConstant = self.updatedConstraintConstants[index]
                        updatedConstraint.constant = updatedConstraintConstant
                    }
                    self.avoidingView!.superview!.setNeedsUpdateConstraints()
                }
                UIView.animate(withDuration: TimeInterval(animationDuration + CGFloat(0.075)), delay: 0, options: UIView.AnimationOptions(rawValue: UInt(animationOptions)), animations: {() -> Void in
                    if self.avoidingViewUsesAutoLayout {
                        self.avoidingView!.superview!.layoutIfNeeded()
                    }
                    else {
                        self.avoidingView!.transform = CGAffineTransform.identity
                    }
                }, completion: {(_ finished: Bool) -> Void in
                    if self.showingAnimationCount <= 0 {
                        self.updatedConstraints.removeAll()
                        self.updatedConstraintConstants.removeAll()
                    }
                })
            }
            if self.avoidingBlock != nil {
                self.avoidingBlock!(isKeyBoardShowing, animationDuration + 0.075, 0, UIView.AnimationOptions(rawValue: UInt(animationOptions)))
            }
        }
        self.isKeyboardVisible = CGRect(x: CGFloat(0), y: CGFloat(0), width: CGFloat(screenSize.width), height: CGFloat(screenSize.height)).intersects(keyboardFrame)
    }
    
    // The triggerView is required if the avoidingView isn't nil
    @objc public class func setAvoidingView(_ avoidingView: UIView?, withTriggerView triggerView: UIView) {
        self.setAvoidingView(avoidingView, withOptionalTriggerView: triggerView)
    }
    
    private class func setAvoidingView(_ avoidingView: UIView?, withOptionalTriggerView triggerView: UIView?) {
        self.initialise()
        
        self._avoidingView = avoidingView
        self.avoidingViewUsesAutoLayout = (avoidingView != nil && avoidingView!.superview != nil) ? avoidingView!.superview!.constraints.count > 0 : false
        
        self.triggerViews.removeAll()
        if triggerView != nil {
            self.triggerViews.append(triggerView!)
        }
        
        self.paddingForCurrentAvoidingView = self.padding
        self.avoidingBlock = nil
        if self.isKeyboardVisible && avoidingView != nil && self.lastNotification != nil {
            // perform avoiding immediately
            self.didChange(self.lastNotification!)
        }
    }
    
    public class func addTriggerView(_ triggerView: UIView) {
        self.triggerViews.append(triggerView)
    }
    
    public class func removeTriggerView(_ triggerView: UIView) {
        if let index = triggerViews.firstIndex(of: triggerView) {
            self.triggerViews.remove(at: index)
        }
    }
    
    public class func removeAll() {
        self.triggerViews.removeAll()
        self.avoidingView = nil
        self.avoidingBlock = nil
    }
    
    private class func initialise() {
        // make sure we only add this once
        if self.avoidingBlock == nil && self.avoidingView == nil {
            NotificationCenter.default.addObserver(forName: UIApplication.didEnterBackgroundNotification, object: nil, queue: OperationQueue.main, using: { notification in
                // Autolayout is reset when app goes into background, so we need to dismiss the keyboard too
                UIApplication.shared.windows.first?.rootViewController?.view.endEditing(true)
            })
            NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillChangeFrameNotification, object: nil, queue: OperationQueue.main, using: { notification in
                self.didChange(notification)
            })
        }
    }
}

