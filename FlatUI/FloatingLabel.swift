import SkyFloatingLabelTextField
import Foundation
import UIKit

public typealias TextUpdatedClosure = ((String?) -> Void)?

@IBDesignable
public class FloatingLabel: SkyFloatingLabelTextField {

    public var updated: TextUpdatedClosure = nil
    public var finished: TextUpdatedClosure = nil

    public var floatingTitleLabel: UILabel = {
        $0.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        $0.alpha = 0.0
        return $0
    }(UILabel())

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        delegate = self
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)
        delegate = self
    }
}

extension FloatingLabel: UITextFieldDelegate {

    open func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {

        guard let text = textField.text else {
            update(with: nil)
            return false
        }

        update(with: (text as NSString).replacingCharacters(in: range, with: string))

        return false
    }

    public func textFieldDidEndEditing(_ textField: UITextField) {
        finished?(textField.text)
    }
    
    public func update(with text: String?) {

        guard let text = text else {
            updated?(nil)
            return
        }

        updated?(text)
    }
}

public extension FloatingLabel {

    public func setTitleLabel(font: UIFont) {
        let titleLabel = floatingTitleLabel
        titleLabel.textColor = titleColor
        titleLabel.font = font

        self.titleLabel.removeFromSuperview()
        self.addSubview(titleLabel)
        self.titleLabel = titleLabel

        setFormatter()
    }

    func setFormatter() {
        titleFormatter = { text -> String in
            return text
        }
    }

}

public protocol StateBindableTextField {
    var updated: TextUpdatedClosure { get set }
    func set(text value: String?, errorMessage error: String?)
}

extension FloatingLabel : StateBindableTextField {}

public extension StateBindableTextField where Self : FloatingLabel {

    public func set(text value: String?, errorMessage error: String? = nil) {
        text = value
        errorMessage = error
    }
}
