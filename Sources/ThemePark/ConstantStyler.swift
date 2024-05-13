import Foundation

/// A placeholder that styles every element the same.
public struct ConstantStyler: Styling {
	private let foregroundColor: PlatformColor
	private let backgroundColor: PlatformColor

	public init(foregroundColor: PlatformColor, backgroundColor: PlatformColor) {
		self.foregroundColor = foregroundColor
		self.backgroundColor = backgroundColor
	}

	public func style(for query: ThemePark.Query) -> Style {
		switch query.key {
		case .editor(.background), .gutter(.background):
			Style(color: backgroundColor, font: nil)
		case .editor(.accessoryBackground):
			Style(color: backgroundColor, font: nil)
		default:
			Style(color: foregroundColor, font: nil)
		}
	}

	public var supportedVariants: Set<Variant> {
		[
			.init(colorScheme: .light, colorSchemeContrast: .standard),
			.init(colorScheme: .dark, colorSchemeContrast: .standard),
		]
	}
}
