import XCTest
import ThemePark

final class XcodeThemeTests: XCTestCase {
	func testDefaultLightTheme() throws {
		let url = try XCTUnwrap(Bundle.module.url(forResource: "Default (Light)", withExtension: "xccolortheme", subdirectory: "Resources"))
		let theme = try XcodeTheme(contentsOf: url)

		XCTAssertEqual(theme.sourceTextBackground, "1 1 1 1")
		XCTAssertEqual(theme.syntaxColors.count, 28)

		XCTAssertEqual(theme.syntaxColors["xcode.syntax.attribute"], "0.505801 0.371396 0.012096 1")

		print(XcodeTheme.builtIn.keys)
		print(XcodeTheme.userInstalled.keys)
	}

	func testSemanticQueries() throws {
		let url = try XCTUnwrap(Bundle.module.url(forResource: "Default (Light)", withExtension: "xccolortheme", subdirectory: "Resources"))
		let theme = try XcodeTheme(contentsOf: url)

		let color = try XCTUnwrap(Color(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0))

		XCTAssertEqual(theme.style(for: .editorBackground), Style(font: nil, color: color))
	}
}
