import Foundation
import SwiftUI

#if canImport(UIKit)
public typealias PlatformColor = UIColor
public typealias PlatformFont = UIFont
#elseif canImport(AppKit)
public typealias PlatformColor = NSColor
public typealias PlatformFont = NSFont
#endif

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
