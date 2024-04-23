import XCTest
import ThemePark

final class XcodeThemeTests: XCTestCase {
	func testDefaultLightTheme() throws {
		let url = try XCTUnwrap(Bundle.module.url(forResource: "Default (Light)", withExtension: "xccolortheme", subdirectory: "Resources"))
		let theme = try XcodeTheme(contentsOf: url)

		XCTAssertEqual(theme.sourceTextBackground, "1 1 1 1")
		XCTAssertEqual(theme.syntaxColors.count, 28)
		XCTAssertEqual(theme.supportedVariants, [.init(colorScheme: .light)])

		XCTAssertEqual(theme.syntaxColors["xcode.syntax.attribute"], "0.505801 0.371396 0.012096 1")

		print(XcodeTheme.builtIn.keys)
		print(XcodeTheme.userInstalled.keys)
	}

	func testSemanticQueries() throws {
		let url = try XCTUnwrap(Bundle.module.url(forResource: "Default (Light)", withExtension: "xccolortheme", subdirectory: "Resources"))
		let theme = try XcodeTheme(contentsOf: url)

		XCTAssertEqual(
			theme.style(for: Query(key: .editor(.background), context: .init(colorScheme: .light))),
			Style(color: PlatformColor(hex: "#ffffff")!)
		)
		XCTAssertEqual(
			theme.style(for: Query(key: .syntax(.text), context: .init(colorScheme: .light))),
			Style(color: PlatformColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.85))
		)
		XCTAssertEqual(
			theme.style(for: Query(key: .syntax(.comment(nil)), context: .init(colorScheme: .light))),
			Style(color: PlatformColor(red: 0.36526, green: 0.421879, blue: 0.475154, alpha: 1.0))
		)
	}
}
