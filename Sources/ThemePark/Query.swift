import SwiftUI

public enum ControlState: Hashable, Sendable, Codable, CaseIterable {
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

public struct Query: Hashable, Sendable, Codable {
	public enum Key: Hashable, Sendable, Codable {
		public enum Editor: Hashable, Sendable, Codable, CaseIterable {
			case background
			case accessoryForeground
			case accessoryBackground
			case cursor
		}

		public enum Gutter: Hashable, Sendable, Codable, CaseIterable {
			case background
			case label
		}

		case editor(Editor)
		case gutter(Gutter)
		case syntax(SyntaxSpecifier)
	}

	public struct Context: Hashable, Sendable, Codable {
		public var controlState: ControlState
		public var variant: Variant

		public init(controlState: ControlState = .active, colorScheme: ColorScheme, colorSchemeContrast: ColorSchemeContrast = .standard) {
			self.init(
				controlState: controlState,
				variant: Variant(colorScheme: colorScheme, colorSchemeContrast: colorSchemeContrast)
			)
		}

		public init(controlState: ControlState = .active, variant: Variant) {
			self.controlState = controlState
			self.variant = variant

		}
	}

	public var key: Key
	public var context: Context

	public init(key: Key, context: Context) {
		self.key = key
		self.context = context
	}
}

extension Query.Key: CaseIterable {
	public static var allCases: [Query.Key] {
		Editor.allCases.map { .editor($0) } +
		Gutter.allCases.map { .gutter($0) } +
		SyntaxSpecifier.allCases.map { .syntax($0) }
	}
}
