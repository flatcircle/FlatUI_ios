/* Improvements:
 * 1. Build character count UI into this component
 * 2. Use built in textColor instead of defaultTextColor
 * 3. Redraw/invalidate self when configuration vars are set (test if needed)
 * 4. IBInspectable and IBDesignable would be great - if we can get the system to work as expected
 */

protocol FCTextViewDelegate: class {
    func textChanged(_ text: String)
}

class FCTextView: UITextView, UITextViewDelegate {
    
    var placeholder: String?
    var placeholderTextColor = UIColor.lightGray
    var defaultTextColor = UIColor.black
    var characterLimit: Int?
    
    weak var customDelegate: FCTextViewDelegate?
    
    override var delegate: UITextViewDelegate? {
        didSet {
            if self.delegate != nil && self.delegate !== self {
                self.delegate = self
                print("Warning: FCTextView must be it's own delegate")
            }
        }
    }
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        self.delegate = self
    }
    
    var isShowingPlaceholder: Bool {
        return self.text == placeholder
    }
    
    var characterCount: Int {
        return isShowingPlaceholder ? 0 : self.text.count
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        if text == "" && textView.text == placeholder {
            return false
        }
        
        if textView.text == placeholder {
            textView.text = ""
        }
        
        if let characterLimit = self.characterLimit {
            return textView.text.count + text.count <= characterLimit
        } else {
            return true
        }
    }
    
    func textViewDidChangeSelection(_ textView: UITextView) {
        if textView.text == placeholder {
            moveCursorToBeginning()
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == placeholder {
            applyPlaceholder()
        } else if textView.text.isEmpty {
            applyPlaceholder()
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            applyPlaceholder()
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        
        if textView.text.isEmpty {
            applyPlaceholder()
        } else if textView.text != placeholder {
            textView.textColor = defaultTextColor
        }
        
        customDelegate?.textChanged(textView.text)
    }
    
    private func applyPlaceholder() {
        self.text = placeholder
        self.textColor = placeholderTextColor
        moveCursorToBeginning()
    }
    
    private func moveCursorToBeginning() {
        let beginning = self.beginningOfDocument
        self.selectedTextRange = self.textRange(from: beginning, to: beginning)
    }
}
