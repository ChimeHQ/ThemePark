import XCTest
import ThemePark

struct MockStyler: Styling {
	func style(for query: Query) -> Style {
		switch query.key {
		case .editor(.background), .editor(.accessoryBackground):
			return Style(color: .red)
		default:
			return Style(color: .blue)
		}
	}
	
	var supportedVariants: Set<Variant> {
		[Variant(colorScheme: .light)]
	}
}

final class CodableStylerTests: XCTestCase {
	func testPassthrough() throws {
		let mock = MockStyler()
		let theme = CodableStyler(mock)
		let context = Query.Context(controlState: .active, variant: Variant(colorScheme: .light))

		XCTAssertEqual(
			mock.style(for: .editor(.background), context: context),
			theme.style(for: .editor(.background), context: context)
		)

		XCTAssertEqual(
			mock.style(for: .syntax(.text), context: context),
			theme.style(for: .syntax(.text), context: context)
		)
	}

	func testPassthroughMismatchedVariant() throws {
		let mock = MockStyler()
		let theme = CodableStyler(mock)
		let context = Query.Context(controlState: .active, variant: Variant(colorScheme: .dark))

		XCTAssertEqual(
			mock.style(for: .editor(.background), context: context),
			theme.style(for: .editor(.background), context: context)
		)

		XCTAssertEqual(
			mock.style(for: .syntax(.text), context: context),
			theme.style(for: .syntax(.text), context: context)
		)
	}

	func testEncodedDecodedPassthrough() throws {
		let mock = MockStyler()
		let theme = CodableStyler(mock)
		let context = Query.Context(controlState: .active, variant: Variant(colorScheme: .light))

		let data = try JSONEncoder().encode(theme)
		let decodedTheme = try JSONDecoder().decode(CodableStyler.self, from: data)


		XCTAssertEqual(
			mock.style(for: .editor(.background), context: context),
			decodedTheme.style(for: .editor(.background), context: context)
		)

		XCTAssertEqual(
			mock.style(for: .syntax(.text), context: context),
			decodedTheme.style(for: .syntax(.text), context: context)
		)
	}
}
