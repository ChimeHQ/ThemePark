import SwiftUI

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

public struct Query: Hashable, Sendable {
	public enum Key: Hashable, Sendable {
		public enum Editor: Hashable, Sendable {
			case background
			case accessoryForeground
			case accessoryBackground
			case cursor
		}

		public enum Gutter: Hashable, Sendable {
			case background
			case label
		}

		case editor(Editor)
		case gutter(Gutter)
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
