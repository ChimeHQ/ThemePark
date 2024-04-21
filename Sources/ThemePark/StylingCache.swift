import Foundation

///Very simple type that will cache the result of style queries.
public final class StylingCache {
	private var cache = [Query: Style]()
	private let styler: any Styling

	public init(styler: any Styling) {
		self.styler = styler
	}
}

extension StylingCache: Styling {
	public func style(for query: Query) -> Style? {
		if let style = cache[query] {
			return style
		}

		let style = styler.style(for: query)

		self.cache[query] = style

		return style
	}

	public var supportedVariants: Set<Variant> {
		styler.supportedVariants
	}
}
