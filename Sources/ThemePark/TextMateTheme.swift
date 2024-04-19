import Foundation

import ColorToolbox

public struct TextMateTheme: Codable {
	public struct Setting: Codable {
		public let name: String?
		public let scope: String?
		public let settings: [String: String]
	}

	public let author: String
	public let name: String
	public let semanticClass: String
	public let uuid: UUID
	public let settings: [Setting]

	public init(with data: Data) throws {
		let decoder = PropertyListDecoder()

		self = try decoder.decode(Self.self, from: data)
	}

	public init(contentsOf url: URL) throws {
		let data = try Data(contentsOf: url, options: [])
		try self.init(with: data)
	}
}

#if canImport(AppKit)
import AppKit

extension TextMateTheme {
	public static var all: [TextMateTheme] {
		let manager = FileManager.default

		let url = try? manager.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: false)

		guard let themesURL = url?.appendingPathComponent("/TextMate/Managed/Bundles/Themes.tmbundle/Themes", isDirectory: true) else {
			return []
		}

		guard let themePaths = try? manager.contentsOfDirectory(at: themesURL, includingPropertiesForKeys: nil) else {
			return []
		}

		return themePaths
			.compactMap { try? TextMateTheme(contentsOf: $0) }
	}
}
#endif

extension TextMateTheme: Styling {
	public func style(for query: Query) -> Style {
		switch query {
		case .editorBackground:
			let colorHex = settings.first?.settings["background"]
			let color = Color(hex: colorHex!)!

			return Style(font: nil, color: color)
		case .syntaxDefault:
			let colorHex = settings.first?.settings["foreground"]
			let color = Color(hex: colorHex!)!

			return Style(font: nil, color: color)
		default:
			return Style(font: nil, color: PlatformColor.black)
		}
	}
}
