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

extension View {
	func plaformOnHover(perform block: @escaping (Bool) -> Void) -> some View {
		#if os(macOS) || os(iOS)
		if #available(iOS 13.4, *) {
			return self.onHover(perform: block)
		}
		#endif

		return self
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
#if os(macOS)
		.init(
			controlState: .init(controlActiveState: controlActiveState),
			colorScheme: colorScheme,
			colorSchemeContrast: colorSchemeContrast
		)
#else
		.init(
			colorScheme: colorScheme,
			colorSchemeContrast: colorSchemeContrast
		)
#endif
	}

	func body(content: Content) -> some View {
		content
			.environment(\.styleQueryContext, context)
			.plaformOnHover(perform: { self.hovering = $0 })
	}
}

extension View {
	/// Adds `EnvironmentValues.styleQueryContext` to the environment for use with ThemePark `Query`.
	public func themeSensitive() -> some View {
		modifier(QueryContextModifier())
	}
}

struct ForegroundColorQueryModifier<Styler: Styling>: ViewModifier {
	@Environment(\.styleQueryContext) private var context
	@State private var hovering = false

	let key: Query.Key
	let styler: Styler

	var foregroundColor: PlatformColor {
		styler.color(for: Query(key: key, context: context))
	}

	func body(content: Content) -> some View {
		content
			.themeSensitive()
			.foregroundColor(Color(foregroundColor))
	}
}

extension View {
	public func foregroundThemeColor<Styler: Styling>(_ key: Query.Key, styler: Styler) -> some View {
		modifier(ForegroundColorQueryModifier(key: key, styler: styler))
	}
}
