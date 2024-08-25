import Foundation
import SwiftUI

#if canImport(UIKit)
public typealias PlatformColor = UIColor
public typealias PlatformFont = UIFont
#elseif canImport(AppKit)
public typealias PlatformColor = NSColor
public typealias PlatformFont = NSFont
#endif

extension PlatformColor {
	/// Makes a darker color lighter and a ligher color darker
	public func emphasize(by ratio: CGFloat) -> PlatformColor {
		let positive = ratio > 0
		let dark = relativeLuminance < 0.5

		return switch (positive, dark) {
		case (true, true):
			lightening(by: ratio)
		case (true, false):
			darkening(by: ratio)
		case (false, true):
			darkening(by: ratio)
		case (false, false):
			lightening(by: ratio)
		}
	}

#if os(macOS)
	static let fallbackForegroundColor: PlatformColor = .labelColor
	static let fallbackBackgroundColor: PlatformColor = .windowBackgroundColor
#else
	static let fallbackForegroundColor: PlatformColor = .label
	static let fallbackBackgroundColor: PlatformColor = .black
#endif
}

extension PlatformFont {
#if os(macOS)
	static let fallbackFont:  PlatformFont = .labelFont(ofSize: 0)
#else
	static let fallbackFont: PlatformFont = .preferredFont(forTextStyle: .body)
#endif
}

public struct Style: Hashable {
	public let color: PlatformColor
	public let font: PlatformFont?

	public init(color: PlatformColor, font: PlatformFont? = nil) {
		self.color = color
		self.font = font
	}

	public var attributes: [NSAttributedString.Key: Any] {
		if let font {
			return [.foregroundColor: color, .font: font]
		}

		return [.foregroundColor: color]
	}
}

extension Style {
	static func fallback(for query: Query) -> Style {
		let lightScheme = query.context.variant.colorScheme == .light

		switch query.key {
		case .editor(.background), .gutter(.background), .editor(.accessoryBackground):
#if os(macOS)
			return Style(color: .windowBackgroundColor)
#else
			return Style(color: lightScheme ? .white : .black)
#endif
		default:
#if os(macOS)
			return Style(color: .labelColor)
#else
			return Style(color: .label)
#endif
		}
	}
}

public struct Variant: Hashable, Sendable {
	public var colorScheme: ColorScheme
	public var colorSchemeContrast: ColorSchemeContrast

	public init(colorScheme: ColorScheme, colorSchemeContrast: ColorSchemeContrast = .standard) {
		self.colorScheme = colorScheme
		self.colorSchemeContrast = colorSchemeContrast
	}

	#if canImport(AppKit)
	public init (appearance: NSAppearance) {
		switch appearance.name {
		case .aqua:
			self.init(colorScheme: .light, colorSchemeContrast: .standard)
		case .accessibilityHighContrastAqua, .accessibilityHighContrastVibrantLight:
			self.init(colorScheme: .light, colorSchemeContrast: .increased)
		case .darkAqua:
			self.init(colorScheme: .dark, colorSchemeContrast: .standard)
		case .accessibilityHighContrastDarkAqua, .accessibilityHighContrastVibrantDark:
			self.init(colorScheme: .light, colorSchemeContrast: .increased)
		default:
			self.init(colorScheme: .light, colorSchemeContrast: .standard)
		}
	}

	public var appearance: NSAppearance? {
		switch (colorScheme, colorSchemeContrast) {
		case (.light, .standard):
			NSAppearance(named: .aqua)
		case (.light, .increased):
			NSAppearance(named: .accessibilityHighContrastAqua)
		case (.dark, .standard):
			NSAppearance(named: .darkAqua)
		case (.dark, .increased):
			NSAppearance(named: .accessibilityHighContrastDarkAqua)
		default:
			NSAppearance(named: .aqua)
		}
	}
	#endif
}

extension Variant: CaseIterable {
	public static let allCases: [Variant] = [
		Variant(colorScheme: .light, colorSchemeContrast: .standard),
		Variant(colorScheme: .light, colorSchemeContrast: .increased),
		Variant(colorScheme: .dark, colorSchemeContrast: .standard),
		Variant(colorScheme: .dark, colorSchemeContrast: .increased),
	]
}

extension Variant: Codable {
	enum CodingKeys: String, CodingKey {
		case colorScheme
		case colorSchemeContrast
	}

	public init(from decoder: any Decoder) throws {
		let values = try decoder.container(keyedBy: CodingKeys.self)

		switch try values.decode(String.self, forKey: .colorScheme) {
		case "dark":
			self.colorScheme = .dark
		case "light":
			self.colorScheme = .light
		default:
			throw DecodingError.dataCorrupted(.init(codingPath: values.codingPath, debugDescription: "unrecogized value for colorScheme"))
		}

		switch try values.decode(String.self, forKey: .colorSchemeContrast) {
		case "increased":
			self.colorSchemeContrast = .increased
		case "standard":
			self.colorSchemeContrast = .standard
		default:
			throw DecodingError.dataCorrupted(.init(codingPath: values.codingPath, debugDescription: "unrecogized value for colorSchemeContrast"))
		}
	}

	public func encode(to encoder: any Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)

		switch colorScheme {
		case .dark:
			try container.encode("dark", forKey: .colorScheme)
		case .light:
			try container.encode("light", forKey: .colorScheme)
		@unknown default:
			try container.encode("light", forKey: .colorScheme)
		}

		switch colorSchemeContrast {
		case .increased:
			try container.encode("increased", forKey: .colorSchemeContrast)
		case .standard:
			try container.encode("standard", forKey: .colorSchemeContrast)
		@unknown default:
			try container.encode("standard", forKey: .colorSchemeContrast)
		}
	}
}

extension Variant: CustomDebugStringConvertible {
	public var debugDescription: String {
		"(\(colorScheme), \(colorSchemeContrast))"
	}
}

public protocol Styling {
	func style(for query: Query) -> Style
	var supportedVariants: Set<Variant> { get }
}

extension Styling {
	public func style(for key: Query.Key, context: Query.Context = .init(colorScheme: .light)) -> Style {
		style(for: Query(key: key, context: context))
	}
	
	public func color(for query: Query) -> PlatformColor {
		style(for: query).color
	}

	public func font(for query: Query) -> PlatformFont? {
		style(for: query).font
	}

	public func highlightsQueryCaptureStyle(for name: String, context: Query.Context) -> Style {
		let specifier = SyntaxSpecifier(highlightsQueryCapture: name) ?? .text

		return style(for: .init(key: .syntax(specifier), context: context))
	}
}
