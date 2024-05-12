import Foundation
import CoreGraphics

enum CodableColor: Codable {
	case components(String, [CGFloat])
	case catalog(String)

	init(_ color: PlatformColor) {
		switch color.type {
		case .componentBased:
			let cgColor = color.cgColor
			let colorSpaceName = cgColor.colorSpace?.name as? String ?? ""
			let components = cgColor.components ?? []

			self = .components(colorSpaceName, components)
		case .catalog:
			self = .catalog(color.colorNameComponent)
		case .pattern:
			preconditionFailure()
		@unknown default:
			preconditionFailure()
		}
	}

	var color: PlatformColor? {
		switch self {
		case let .components(spaceName, components):
			guard
				let cgColorSpace = CGColorSpace(name: spaceName as CFString),
				let cgColor = CGColor(colorSpace: cgColorSpace, components: components)
			else {
				return nil
			}

			return PlatformColor(cgColor: cgColor)
		case let .catalog(name):
			return PlatformColor(named: name)
		}
	}
}

struct CodableFont: Codable {
	let name: String
	let size: CGFloat

	init(_ font: PlatformFont) {
		self.name = font.fontName
		self.size = font.pointSize
	}
	
	var font: PlatformFont? {
		PlatformFont(name: name, size: size)
	}
}

struct CodableStyle: Codable {
	let codableColor: CodableColor
	let codableFont: CodableFont?

	init(style: Style) {
		self.codableColor = CodableColor(style.color)
		self.codableFont = style.font.map { CodableFont($0) }
	}

	var style: Style? {
		guard let color = codableColor.color else {
			return nil
		}

		return Style(color: color, font: codableFont?.font)
	}
}

/// Capable of encoding and decoding all possible queries within a Styler.
///
/// > Warning: Pretty much everything about this process is inefficient. It's here for convenience only.
public struct CodableStyler {
	private let styles: [Query: CodableStyle]
	public let supportedVariants: Set<Variant>

	public init(_ styler: any Styling) {
		self.supportedVariants = styler.supportedVariants

		let allContexts = Variant.allCases.flatMap { variant in
			ControlState.allCases.map { Query.Context(controlState: $0, variant: variant) }
		}

		var styles = [Query: CodableStyle]()
		for key in Query.Key.allCases {
			for context in allContexts {
				let query = Query(key: key, context: context)
				let style = styler.style(for: query)

				styles[query] = CodableStyle(style: style)
			}
		}

		self.styles = styles
	}
}

extension CodableStyler: Styling {
	public func style(for query: Query) -> Style {
		styles[query]?.style ?? Style.fallback(for: query)
	}
}

extension CodableStyler: Codable {
	enum CodingKeys: String, CodingKey {
		case styles
		case supportedVariants
	}

	public init(from decoder: any Decoder) throws {
		let values = try decoder.container(keyedBy: CodingKeys.self)

		self.supportedVariants = try values.decode(Set<Variant>.self, forKey: .supportedVariants)
		self.styles = try values.decode([Query: CodableStyle].self, forKey: .styles)
	}
	
	public func encode(to encoder: any Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)

		try container.encode(supportedVariants, forKey: .supportedVariants)
		try container.encode(styles, forKey: .styles)
	}
}
