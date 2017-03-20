import Foundation
import UIKit

let rootViewSwapDuration = 0.68

extension UIView {
    class func animateRootSwap(from window: UIWindow, to viewController: UIViewController) {
        UIView.transition(from: window.rootViewController!.view, to: viewController.view, duration: rootViewSwapDuration, options: [.transitionCrossDissolve], completion: {
            _ in
            window.rootViewController = viewController
        })
    }
}
