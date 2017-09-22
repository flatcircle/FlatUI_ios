import Foundation

@IBDesignable
public class RadioButton: UIView {

    private var buttonColor: UIColor?
    public var color: UIColor? {
        set {
            buttonColor = newValue
        }
        get {
            return buttonColor ?? tintColor
        }
    }

    let damping = CGFloat(7.0)
    let velocity = CGFloat(16.0)
    let duration = 0.3
    var hasInitialised = false
    var centerView: UIView = UIView()

    public required init?(coder aDecoder: NSCoder) {
        isSelected = false

        super.init(coder: aDecoder)

        initialize()
    }

    override init(frame: CGRect) {
        isSelected = false
        super.init(frame: frame)
        initialize()
    }

    public override func prepareForInterfaceBuilder() {
        isSelected = true
        initialize()
    }

    public var isSelected: Bool {
        didSet {
            DispatchQueue.main.async {
                if self.isSelected {
                    self.startSelectAnimation()
                } else {
                    self.deselectAnimation()
                }
            }
        }
    }
}

extension RadioButton {
    func initialize() {
        centerView = UIView(frame: frame)
        self.addSubview(centerView)
    }

    override public func layoutSubviews() {

        guard !hasInitialised else {
            return
        }

        hasInitialised = true

        self.layer.cornerRadius = frame.width / 2
        self.layer.masksToBounds = true
        self.layer.borderColor = color?.cgColor
        self.layer.borderWidth = CGFloat(2)

        centerView.frame = frame
        centerView.center = CGPoint(x: self.bounds.midX,
                                    y: self.bounds.midY)
        centerView.layer.cornerRadius = centerView.frame.width / 2
        centerView.layer.masksToBounds = true
        centerView.backgroundColor = color

        self.centerView.transform = CGAffineTransform(scaleX: 0.0, y: 0.0)
    }

    func startSelectAnimation() {
        UIView.animate(withDuration: self.duration, delay: 0.0, usingSpringWithDamping: self.damping, initialSpringVelocity: self.velocity, options: UIViewAnimationOptions.allowUserInteraction, animations: { [unowned self] in
            self.centerView.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        }) { _ in
            if self.isSelected {
                self.selectedAnimationFinish()
            } else {
                self.deselectAnimation()
            }
        }
    }

    func selectedAnimationFinish() {
        UIView.animate(withDuration: self.duration, delay: 0, usingSpringWithDamping: self.damping, initialSpringVelocity: self.velocity, options: UIViewAnimationOptions.allowUserInteraction, animations: { [unowned self] in
            self.centerView.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        }) { _ in
            if !self.isSelected {
                self.deselectAnimation()
            }
        }
    }

    func deselectAnimation() {
        UIView.animate(withDuration: self.duration, delay: 0, usingSpringWithDamping: self.damping, initialSpringVelocity: self.velocity, options: UIViewAnimationOptions.allowUserInteraction, animations: { [unowned self] in
            self.centerView.transform = CGAffineTransform(scaleX: 0.0, y: 0.0)
            }, completion: nil)
    }
}
