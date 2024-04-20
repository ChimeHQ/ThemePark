import SwiftUI

struct QueryContextKey: EnvironmentKey {
	public static let defaultValue = Query.Context(colorScheme: .light)
}

extension EnvironmentValues {
	public var styleQueryContext: Query.Context {
		get { self[QueryContextKey.self] }
		set { self[QueryContextKey.self] = newValue }
	}
}

struct QueryContextModifier: ViewModifier {
#if os(macOS)
	@Environment(\.controlActiveState) private var controlActiveState
#endif
	@Environment(\.colorScheme) private var colorScheme
	@Environment(\.colorSchemeContrast) private var colorSchemeContrast
	@State private var hovering = false

	private var context: Query.Context {
		.init(
			controlState: .init(controlActiveState: controlActiveState),
			colorScheme: colorScheme,
			colorSchemeContrast: colorSchemeContrast
		)
	}

	func body(content: Content) -> some View {
		content
			.environment(\.styleQueryContext, context)
			.onHover(perform: { self.hovering = $0 })
	}
}

extension View {
	/// Adds `EnvironmentValues.styleQueryContext` to the environment for use with ThemePark `Query`.
	public func themeSensitive() -> some View {
		modifier(QueryContextModifier())
	}
}
