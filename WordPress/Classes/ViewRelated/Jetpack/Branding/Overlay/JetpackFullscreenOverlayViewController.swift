import UIKit

class JetpackFullscreenOverlayViewController: UIViewController {

    // MARK: Variables

    private let config: JetpackFullscreenOverlayConfig

    // MARK: Lazy Views

    private lazy var closeButtonItem: UIBarButtonItem = {
        let closeButton = UIButton()

        let configuration = UIImage.SymbolConfiguration(pointSize: Constants.closeButtonSymbolSize, weight: .bold)
        closeButton.setImage(UIImage(systemName: "xmark", withConfiguration: configuration), for: .normal)
        closeButton.tintColor = .secondaryLabel
        closeButton.backgroundColor = .quaternarySystemFill

        NSLayoutConstraint.activate([
            closeButton.widthAnchor.constraint(equalToConstant: Constants.closeButtonRadius),
            closeButton.heightAnchor.constraint(equalTo: closeButton.widthAnchor)
        ])
        closeButton.layer.cornerRadius = Constants.closeButtonRadius * 0.5

        closeButton.addTarget(self, action: #selector(closeButtonPressed), for: .touchUpInside)

        return UIBarButtonItem(customView: closeButton)
    }()

    // MARK: Outlets

    @IBOutlet weak var contentStackView: UIStackView!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var footnoteLabel: UILabel!
    @IBOutlet weak var learnMoreButton: UIButton!
    @IBOutlet weak var switchButton: UIButton!
    @IBOutlet weak var continueButton: UIButton!

    // MARK: Initializers

    init(with config: JetpackFullscreenOverlayConfig) {
        self.config = config
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        configureNavigationBar()
        applyStyles()
        setupContent()
        setupColors()
        setupFonts()
        setupButtonInsets()
    }

    // MARK: Helpers

    private func configureNavigationBar() {
        addCloseButtonIfNeeded()

        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = .systemBackground
        appearance.shadowColor = .clear
        navigationItem.standardAppearance = appearance
        navigationItem.compactAppearance = appearance
        navigationItem.scrollEdgeAppearance = appearance
        if #available(iOS 15.0, *) {
            navigationItem.compactScrollEdgeAppearance = appearance
        }
    }

    private func addCloseButtonIfNeeded() {
        guard config.shouldShowCloseButton else {
            return
        }

        navigationItem.rightBarButtonItem = closeButtonItem
    }

    private func applyStyles() {
        iconImageView.clipsToBounds = false
    }

    private func setupContent() {
        iconImageView.image = config.icon
        titleLabel.text = config.title
        subtitleLabel.text = config.subtitle
        footnoteLabel.text = config.footnote
        switchButton.setTitle(config.switchButtonText, for: .normal)
        continueButton.setTitle(config.continueButtonText, for: .normal)
        footnoteLabel.isHidden = config.footnoteIsHidden
        learnMoreButton.isHidden = config.learnMoreButtonIsHidden
        continueButton.isHidden = config.continueButtonIsHidden
    }

    private func setupColors() {

    }

    private func setupFonts() {

    }

    private func setupButtonInsets() {
        if #available(iOS 15.0, *) {
            // Continue Button
            var continueButtonConfig: UIButton.Configuration = .plain()
            continueButtonConfig.contentInsets = Constants.continueButtonContentInsets
            continueButton.configuration = continueButtonConfig

            // Learn More Button
            var learnMoreButtonConfig: UIButton.Configuration = .plain()
            learnMoreButtonConfig.contentInsets = Constants.learnMoreButtonContentInsets
            learnMoreButton.configuration = learnMoreButtonConfig
        } else {
            // Continue Button
            continueButton.contentEdgeInsets = Constants.continueButtonContentEdgeInsets

            // Learn More Button
            learnMoreButton.contentEdgeInsets = Constants.learnMoreButtonContentEdgeInsets
            learnMoreButton.flipInsetsForRightToLeftLayoutDirection()
        }
    }

    // MARK: Actions

    @objc private func closeButtonPressed(sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
}

// MARK: Constants

private extension JetpackFullscreenOverlayViewController {
    enum Strings {
    }

    enum Constants {
        static let closeButtonRadius: CGFloat = 30
        static let closeButtonSymbolSize: CGFloat = 16
        static let continueButtonContentInsets = NSDirectionalEdgeInsets(top: 0, leading: 24, bottom: 0, trailing: 24)
        static let continueButtonContentEdgeInsets = UIEdgeInsets(top: 0, left: 24, bottom: 0, right: 24)
        static let learnMoreButtonContentInsets = NSDirectionalEdgeInsets(top: 4, leading: 0, bottom: 4, trailing: 24)
        static let learnMoreButtonContentEdgeInsets = UIEdgeInsets(top: 4, left: 0, bottom: 4, right: 24)
    }
}
