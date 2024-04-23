import Foundation
import SwiftUI

#if canImport(UIKit)
public typealias PlatformColor = UIColor
public typealias PlatformFont = UIFont
#elseif canImport(AppKit)
public typealias PlatformColor = NSColor
public typealias PlatformFont = NSFont
#endif

public enum ControlState: Hashable, Sendable {
	case active
	case inactive
	case hover

#if os(macOS)
	init(controlActiveState: ControlActiveState) {
		switch controlActiveState {
		case .active, .key:
			self = .active
		case .inactive:
			self = .inactive
		@unknown default:
			self = .active
		}
	}
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

public struct Variant: Hashable, Sendable {
	public var colorScheme: ColorScheme
	public var colorSchemeContrast: ColorSchemeContrast

	public init(colorScheme: ColorScheme, colorSchemeContrast: ColorSchemeContrast = .standard) {
		self.colorScheme = colorScheme
		self.colorSchemeContrast = colorSchemeContrast
	}
}

public struct Query: Hashable, Sendable {
	public enum Key: Hashable, Sendable {
		public enum Editor: Hashable, Sendable {
			case background
			case accessoryForeground
			case accessoryBackground
			case cursor
		}

		case editor(Editor)
		case syntax(SyntaxSpecifier)
	}

	public struct Context: Hashable, Sendable {
		public var controlState: ControlState
		public var variant: Variant

		public init(controlState: ControlState = .active, colorScheme: ColorScheme, colorSchemeContrast: ColorSchemeContrast = .standard) {
			self.controlState = controlState
			self.variant = Variant(colorScheme: colorScheme, colorSchemeContrast: colorSchemeContrast)
		}
	}

	public var key: Key
	public var context: Context

	public init(key: Key, context: Context) {
		self.key = key
		self.context = context
	}
}

public protocol Styling {
	func style(for query: Query) -> Style
	var supportedVariants: Set<Variant> { get }
}

extension Styling {
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
