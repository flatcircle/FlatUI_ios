import UIKit

open class KeyboardAwareViewController: UIViewController {

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
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: .UIKeyboardWillHide, object: nil)
    }

    private func addTapGestures() {
        let viewTap = UITapGestureRecognizer(target: self, action:#selector(endEditing))
        viewTap.cancelsTouchesInView = false
        view.addGestureRecognizer(viewTap)
    }

    func keyboardWillHide(notification: Notification) {
        if let userInfo = notification.userInfo, let animationDuration = userInfo[UIKeyboardAnimationDurationUserInfoKey] as? Double {

            constraintToAnimateOnKeyboardNotification?.constraint.constant = constraintToAnimateOnKeyboardNotification?.originalValue ?? 0

            UIView.animate(withDuration: animationDuration, animations: { [unowned self] _ in
                self.view.layoutIfNeeded()
            })
        }
    }

    func keyboardWillShow(notification: Notification) {
        if let userInfo = notification.userInfo,
            let frame = (userInfo[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue,
            let animationDuration = userInfo[UIKeyboardAnimationCurveUserInfoKey] as? Double {
            let newFrame = view.convert(frame, from: UIApplication.shared.delegate?.window!)

            if let currentResponder = self.view.firstResponderView() {

                let maxYPading: CGFloat = 65
                let textFieldFrame = view.convert(currentResponder.frame, from: currentResponder.superview)
                let frameToTest = textFieldFrame.offsetBy(dx: 0, dy: maxYPading)
                let keyboardFrameOffsetFromBottom  = self.view.frame.height - newFrame.height

                if keyboardFrameOffsetFromBottom < frameToTest.maxY {

                    constraintToAnimateOnKeyboardNotification?.constraint.constant += abs(keyboardFrameOffsetFromBottom - frameToTest.maxY)

                    UIView.animate(withDuration: animationDuration, animations: { [unowned self] _ in
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
