import UIKit

open class KeyboardAwareViewController: UIViewController {
    
    
    public var toolbarPadding:CGFloat = 0
    private var keyboardIsVisible = false
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        makeViewKeyboardAware()
    }
    
    open var constraintToAnimateOnKeyboardNotification: (constraint: NSLayoutConstraint, originalValue: CGFloat)? {
        return nil
    }
    
    func makeViewKeyboardAware() {
        addTapGestures()
        addKeyboardListeners()
    }
    
    @objc private func endEditing() {
        self.view.endEditing(true)
    }
    
    private func addKeyboardListeners() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    private func addTapGestures() {
        let viewTap = UITapGestureRecognizer(target: self, action:#selector(endEditing))
        viewTap.cancelsTouchesInView = false
        view.addGestureRecognizer(viewTap)
    }
    
    @objc func keyboardWillHide(notification: Notification) {
        if let userInfo = notification.userInfo, let animationDuration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double {
            
            constraintToAnimateOnKeyboardNotification?.constraint.constant = constraintToAnimateOnKeyboardNotification?.originalValue ?? 0
            keyboardIsVisible = false
            UIView.animate(withDuration: animationDuration, animations: { [unowned self] in
                self.view.layoutIfNeeded()
            })
        }
    }
    
    @objc func keyboardWillShow(notification: Notification) {
        if let userInfo = notification.userInfo,
            let frame = (userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue,
            let animationDuration = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? Double {
            let newFrame = view.convert(frame, from: UIApplication.shared.delegate?.window!)
            
            if let currentResponder = self.view.firstResponderView() {
                
                let maxYPading: CGFloat = 65
                let textFieldFrame = view.convert(currentResponder.frame, from: currentResponder.superview)
                let frameToTest = textFieldFrame.offsetBy(dx: 0, dy: maxYPading)
                let keyboardFrameOffsetFromBottom  = self.view.frame.height - newFrame.height
                
                if keyboardFrameOffsetFromBottom < frameToTest.maxY {
                    constraintToAnimateOnKeyboardNotification?.constraint.constant += abs(keyboardFrameOffsetFromBottom - frameToTest.maxY)
                    
                    //only add toolbar padding once
                    if !keyboardIsVisible{
                        constraintToAnimateOnKeyboardNotification?.constraint.constant += toolbarPadding
                        keyboardIsVisible = true
                    }
                    UIView.animate(withDuration: animationDuration, animations: { [unowned self] in
                        self.view.layoutIfNeeded()
                    })
                }
            }
        }
    }
    
}

extension UIView {
    func firstResponderView() -> UIView? {
        if self.isFirstResponder {
            return self
        }
        
        for subView in self.subviews {
            if let activeView = subView.firstResponderView() {
                return activeView
            }
        }
        
        return nil
    }
}
