import SwiftMessages

public protocol TopPopupable {
    func show(error description: String)
    func show(error: String, description: String)
}

public struct TopPopup: TopPopupable {

    public func show(error description: String) {
       show(error:  "An error has occured", description: description)
    }

    public func show(error: String, description: String) {

        let view = defaultView()

        view.configureContent(title: error, body: description, iconImage:  UIImage(named: "errorIconLight")!.withRenderingMode(.alwaysTemplate))

        SwiftMessages.show(config: defaultConfig(), view: view)
    }

    private func defaultView() -> MessageView {
        let view = MessageView.viewFromNib(layout: .CardView)
        view.configureTheme(.error)
        view.configureDropShadow()
        view.iconImageView?.tintColor = .white
        return view
    }

    private func defaultConfig() -> SwiftMessages.Config {
        var config = SwiftMessages.Config()
        config.presentationStyle = .top
        config.presentationContext = .window(windowLevel: UIWindowLevelStatusBar)
        config.dimMode = .gray(interactive: true)
        return config
    }
}

public typealias ErrorMessage = (title: String, description: String)

public struct ErrorMessages {
    static let noInternet: ErrorMessage = ("No internet connection", "Please switch on your internet")
}

public let NoInternet = ErrorMessages.noInternet
