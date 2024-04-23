import XCTest
import ThemePark

final class BBEditThemeTests: XCTestCase {
	func testDarkTheme() throws {
		let url = try XCTUnwrap(Bundle.module.url(forResource: "BBEdit Dark", withExtension: "bbColorScheme", subdirectory: "Resources"))
		let theme = try BBEditTheme(contentsOf: url)

		XCTAssertEqual(theme.backgroundColor, "rgba(0.077525,0.077522,0.077524,1.000000)")
		XCTAssertEqual(theme.syntaxColors["com.barebones.bblm.code"], "hsla(0.00, 0.00, 0.68, 1.00)")
	}

	func testSemanticQueries() throws {
		let url = try XCTUnwrap(Bundle.module.url(forResource: "BBEdit Dark", withExtension: "bbColorScheme", subdirectory: "Resources"))
		let theme = try BBEditTheme(contentsOf: url)

		XCTAssertEqual(
			theme.style(for: Query(key: .editor(.background), context: .init(colorScheme: .light))),
			Style(color: PlatformColor(red: 0.077525, green: 0.077522, blue: 0.077524, alpha: 1.000000))
		)
		XCTAssertEqual(
			theme.style(for: Query(key: .syntax(.text), context: .init(colorScheme: .light))),
			Style(color: PlatformColor(hue: 0.0, saturation: 0.0, brightness: 0.68, alpha: 1.0))
		)
	}
}

