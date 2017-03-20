import Foundation
import UIKit

public enum ButtonAnimationState: Int {
    case start = 0
    case stop = 1
    case completed = 2
}

@IBDesignable
public class TKTransitionSubmitButton: UIButton, UIViewControllerTransitioningDelegate, CAAnimationDelegate {

    lazy var spiner: SpinerLayer! = {
        let s = SpinerLayer(frame: self.frame)
        self.layer.addSublayer(s)
        return s
    }()

    @IBInspectable open var spinnerColor: UIColor = UIColor.white {
        didSet {
            spiner.spinnerColor = spinnerColor
        }
    }

    open var animationState: ButtonAnimationState = .stop {
        didSet {
            switch animationState {
            case .start:
                startLoadingAnimation()
            case .stop:
                setOriginalState()
            case .completed:
                stopAnimation()
            }
        }
    }

    let springGoEase = CAMediaTimingFunction(controlPoints: 0.45, -0.36, 0.44, 0.92)
    let shrinkCurve = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
    let expandCurve = CAMediaTimingFunction(controlPoints: 0.95, 0.02, 1, 0.05)
    let shrinkDuration: CFTimeInterval  = 0.1
    @IBInspectable open var normalCornerRadius: CGFloat? = 0.0 {
        didSet {
            self.layer.cornerRadius = normalCornerRadius!
        }
    }

    var cachedTitle: String?

    override public func layoutSubviews() {
        super.layoutSubviews()
        self.setup()
    }

    func setup() {
        self.clipsToBounds = true
        spiner.spinnerColor = spinnerColor
        self.layer.cornerRadius = self.frame.height / 2
    }

    open func startLoadingAnimation() {
        self.cachedTitle = title(for: UIControlState())
        self.setTitle("", for: UIControlState())
        UIView.animate(withDuration: 0.1, animations: { () -> Void in
            self.layer.cornerRadius = self.frame.height / 2
            self.shrink()
            self.spiner.animation()
            }, completion: nil)

    }

    open func stopAnimation() {
        self.expand()
        self.spiner.stopAnimation()
    }

    open func animate(_ duration: TimeInterval, completion:(() -> Void)?) {
        startLoadingAnimation()
    }

    open func setOriginalState() {
        self.returnToOriginalState()
        self.spiner.stopAnimation()
    }

    public func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        let a = anim as! CABasicAnimation
        if a.keyPath == "transform.scale" {
            Timer.schedule(delay: 1) { _ in
                self.returnToOriginalState()
            }
        }
    }

    open func returnToOriginalState() {
        self.layer.removeAllAnimations()
        self.setTitle(self.cachedTitle, for: UIControlState())
        self.spiner.stopAnimation()
    }

    func shrink() {
        let shrinkAnim = CABasicAnimation(keyPath: "bounds.size.width")
        shrinkAnim.fromValue = frame.width
        shrinkAnim.toValue = frame.height
        shrinkAnim.duration = shrinkDuration
        shrinkAnim.timingFunction = shrinkCurve
        shrinkAnim.fillMode = kCAFillModeForwards
        shrinkAnim.isRemovedOnCompletion = false
        layer.add(shrinkAnim, forKey: shrinkAnim.keyPath)
    }

    func expand() {
        let expandAnim = CABasicAnimation(keyPath: "transform.scale")
        expandAnim.fromValue = 1.0
        expandAnim.toValue = 28.0
        expandAnim.timingFunction = expandCurve
        expandAnim.duration = 0.28
        expandAnim.delegate = self
        expandAnim.fillMode = kCAFillModeForwards
        expandAnim.isRemovedOnCompletion = false
        layer.add(expandAnim, forKey: expandAnim.keyPath)
    }

}
