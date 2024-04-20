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

public struct Style : Hashable {
	public let font: PlatformFont?
	public let color: PlatformColor

	public init(font: PlatformFont?, color: PlatformColor) {
		self.font = font
		self.color = color
	}

	public init?(font: PlatformFont?, color: PlatformColor?) {
		guard let color else { return nil}
		
		self.font = font
		self.color = color
	}
}

public struct Specifier: Hashable, Sendable {
	public var components: [String]

	public init(components: [String]) {
		self.components = components
	}

	public init(_ string: String) {
		self.components = string.split(separator: ".").map { String($0) }
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
	public enum Key : Hashable, Sendable {
		case editorBackground

		case syntaxDefault
		case syntax(Specifier)
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
	func style(for query: Query) -> Style?
}

extension Styling {
	public func style(for key: Query.Key) -> Style? {
		style(for: Query(key: key, context: .init(colorScheme: .light)))
	}
}
