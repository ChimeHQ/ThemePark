import Foundation

import ColorToolbox

public struct TextMateTheme: Codable, Hashable, Sendable {
	public struct Setting: Codable, Hashable, Sendable {
		public let name: String?
		public let scope: String?
		public let settings: [String: String]

		var scopeComponents: Set<String> {
			let scopeString = (scope ?? "").trimmingCharacters(in: .whitespacesAndNewlines)

			let components = scopeString.components(separatedBy: ",")

			return Set(components)
		}
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

		guard let themesURL = url?.appendingPathComponent("TextMate/Managed/Bundles/Themes.tmbundle/Themes", isDirectory: true) else {
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
	private var fallbackForegroundColor: PlatformColor {
		let colorHex = settings.first?.settings["foreground"]

		return colorHex.flatMap { PlatformColor(hex: $0) } ?? .fallbackForegroundColor
	}

	private var fallbackBackgroundColor: PlatformColor {
		let colorHex = settings.first?.settings["background"]

		return colorHex.flatMap { PlatformColor(hex: $0) } ?? .fallbackBackgroundColor
	}

	private func resolveScope(_ scope: String) -> Style {
		let colorHex = settings.first(where: { $0.scopeComponents.contains(scope) })?.settings["foreground"]

		let color = colorHex.flatMap { PlatformColor(hex: $0) } ?? fallbackForegroundColor

		return Style(color: color, font: nil)
	}

	public func style(for query: Query) -> Style {
		switch query.key {
		case .editor(.background), .gutter(.background):
			let color = fallbackBackgroundColor

			return Style(color: color, font: nil)
		case .syntax(.text), .gutter(.label):
			let color = fallbackForegroundColor

			return Style(color: color, font: nil)
		case .editor(.cursor):
			let colorHex = settings.first?.settings["caret"] ?? ""
			let color = PlatformColor(hex: colorHex) ?? fallbackForegroundColor

			return Style(color: color, font: nil)
		case .syntax(.comment(_)):
			return resolveScope("comment")
		case .syntax(.keyword(_)):
			return resolveScope("keyword")
		case .syntax(.literal(.string(_))):
			return resolveScope("string")
		case .syntax(.literal(_)):
			return resolveScope("constant")
		case .syntax(.identifier(.variable)):
			return resolveScope("variable")
		case .syntax(.identifier(.parameter)):
			return resolveScope("variable")
		case .syntax(.identifier(.type)):
			return resolveScope("entity")
		case .syntax(.identifier(.constant)):
			return resolveScope("constant")
		case .editor(.accessoryForeground):
			let color = fallbackForegroundColor

			return Style(color: color, font: nil)
		case .editor(.accessoryBackground):
			let colorHex = settings.first?.settings["background"]
			let color = PlatformColor(hex: colorHex!)!.emphasize(by: 0.4)

			return Style(color: color)
		default:
			return Style(color: .red, font: nil)
		}
	}

	public var supportedVariants: Set<Variant> {
		guard let colorHex = settings.first?.settings["background"] else {
			return [.init(colorScheme: .light)]
		}

		let color = PlatformColor(hex: colorHex) ?? .white
		let isDark = color.relativeLuminance < 0.5

		return isDark ? [.init(colorScheme: .dark)] : [.init(colorScheme: .light)]
	}
}
