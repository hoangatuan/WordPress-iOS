import SwiftUI
import DesignSystem

struct AvatarsView: View {
    enum Style {
        case single(URL)
        case double(URL, URL)
        case triple(URL, URL, URL)

        var diameter: CGFloat {
            switch self {
            case .single:
                return 40
            case .double:
                return 34
            case .triple:
                return 28
            }
        }
    }

    private let style: Style

    init(style: Style) {
        self.style = style
    }

    var body: some View {
        switch style {
        case let .single(primaryURL):
            avatar(url: primaryURL)
        case let .double(primaryURL, secondaryURL):
            doubleAvatarView(
                primaryURL: primaryURL,
                secondaryURL: secondaryURL
            )
        case let .triple(primaryURL, secondaryURL, tertiaryURL):
            tripleAvatarView(
                primaryURL: primaryURL,
                secondaryURL: secondaryURL,
                tertiaryURL: tertiaryURL
            )
        }
    }

    private func avatar(url: URL) -> some View {
        AsyncImage(url: url) { image in
            image.resizable()
                .background(Color.DS.Background.primary) // Only for testing
        } placeholder: {
            Color.DS.Background.secondary
        }
        .frame(width: style.diameter, height: style.diameter)
        .clipShape(Circle())
    }

    private func doubleAvatarView(primaryURL: URL, secondaryURL: URL) -> some View {
        ZStack {
            HStack {
                avatar(url: secondaryURL)
                Spacer().frame(width: 20)
            }
            HStack {
                Spacer().frame(width: 20)
                avatar(url: primaryURL)
            }
        }
        .frame(height: style.diameter)
    }

    private func tripleAvatarView(
        primaryURL: URL,
        secondaryURL: URL,
        tertiaryURL: URL
    ) -> some View {
        ZStack {
            HStack {
                avatar(url: tertiaryURL)
                Spacer().frame(width: Length.Padding.medium)
            }
            VStack {
                avatar(url: secondaryURL)
                Spacer().frame(height: Length.Padding.large)
            }
            HStack {
                Spacer().frame(width: Length.Padding.medium)
                avatar(url: primaryURL)
            }
        }
        .frame(height: 44)
    }
}

#if DEBUG
#Preview {
    VStack(spacing: Length.Padding.medium) {
        AvatarsView(
            style: .single(URL(string: "https://i.pickadummy.com/index.php?imgsize=40x40")!)
        )
        AvatarsView(
            style: .double(
                URL(string: "https://i.pickadummy.com/index.php?imgsize=34x34")!,
                URL(string: "https://i.pickadummy.com/index.php?imgsize=34x34")!
            )
        )
        AvatarsView(
            style: .triple(
                URL(string: "https://i.pickadummy.com/index.php?imgsize=28x28")!,
                URL(string: "https://i.pickadummy.com/index.php?imgsize=28x28")!,
                URL(string: "https://i.pickadummy.com/index.php?imgsize=28x28")!
            )
        )
    }
}
#endif
