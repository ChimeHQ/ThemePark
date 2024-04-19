import XCTest
import ThemePark

final class TextMateThemeTests: XCTestCase {
	func testBackboardTheme() throws {
		let url = try XCTUnwrap(Bundle.module.url(forResource: "Blackboard", withExtension: "tmTheme", subdirectory: "Resources"))
		let theme = try TextMateTheme(contentsOf: url)

		XCTAssertEqual(theme.uuid, UUID(uuidString: "A2C6BAA7-90D0-4147-BBF5-96B0CD92D109"))
		XCTAssertEqual(theme.settings.count, 27)

		let setting = theme.settings[0]

		XCTAssertNil(setting.name)
		XCTAssertNil(setting.scope)

		XCTAssertEqual(setting.settings["background"], "#0C1021")
	}

	func testSemanticQueries() throws {
		let url = try XCTUnwrap(Bundle.module.url(forResource: "Blackboard", withExtension: "tmTheme", subdirectory: "Resources"))
		let theme = try TextMateTheme(contentsOf: url)

		let color = try XCTUnwrap(Color(hex: "#0C1021"))
		
		XCTAssertEqual(theme.style(for: .editorBackground), Style(font: nil, color: color))
	}
}
