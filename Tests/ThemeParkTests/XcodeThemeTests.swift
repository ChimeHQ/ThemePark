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
}
