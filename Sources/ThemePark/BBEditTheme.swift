import Foundation

import ColorToolbox

public struct BBEditTheme: Decodable, Hashable, Sendable {
	public let backgroundColor: String
	public let syntaxColors: [String: String]

	public init(with data: Data) throws {
		let decoder = PropertyListDecoder()

		self = try decoder.decode(Self.self, from: data)
	}

	public init(contentsOf url: URL) throws {
		let data = try Data(contentsOf: url, options: [])
		try self.init(with: data)
	}

	public init(from decoder: any Decoder) throws {
		let container = try decoder.singleValueContainer()
		let values = try container.decode([String: String].self)

		self.backgroundColor = values["BackgroundColor"] ?? ""

		var colors = [String: String]()

		for pair in values {
			switch pair.key {
			case  "BackgroundColor":
				break
			default:
				colors[pair.key] = pair.value
			}
		}

		self.syntaxColors = colors
	}
}

#if canImport(AppKit)
import AppKit

extension BBEditTheme {
	public static var all: [BBEditTheme] {
		let manager = FileManager.default

		let url = try? manager.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: false)

		guard let themesURL = url?.appendingPathComponent("BBEdit/Color Schemes/", isDirectory: true) else {
			return []
		}

		guard let themePaths = try? manager.contentsOfDirectory(at: themesURL, includingPropertiesForKeys: nil) else {
			return []
		}

		return themePaths
			.compactMap { try? BBEditTheme(contentsOf: $0) }
	}
}
#endif

extension BBEditTheme: Styling {
	private func platformColor(for value: String?) -> PlatformColor? {
		return nil
	}

	public func style(for query: Query) -> Style? {
		switch query.key {
		case .editorBackground:
			let color = platformColor(for: backgroundColor) ?? .white

			return Style(font: nil, color: color)
		case .syntaxDefault:
			let color = platformColor(for: syntaxColors["com.barebones.bblm.code"]) ?? .black

			return Style(font: nil, color: color)
		default:
			return Style(font: nil, color: PlatformColor.black)
		}
	}

	public var supportedVariants: Set<Variant> {
		let color = platformColor(for: backgroundColor) ?? .white
		let isDark = color.relativeLuminance < 0.5

		return isDark ? [.init(colorScheme: .dark)] : [.init(colorScheme: .light)]
	}
}
