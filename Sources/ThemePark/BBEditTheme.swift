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

extension FileManager {
	func applicationSupport(subDirectory component: String) throws -> URL? {
		let root = try? url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: false)

		return root?.appendingPathComponent(component, isDirectory: true)
	}

	func namedURLs(at url: URL, extension ext: String) throws -> [(String, URL)] {
		try contentsOfDirectory(at: url, includingPropertiesForKeys: nil)
			.compactMap { url in
				guard url.pathExtension == ext else { return nil }

				let name = url.deletingPathExtension().lastPathComponent

				return (name, url)
			}
	}
}

extension BBEditTheme {
	public static var userInstalled: [String: BBEditTheme] {
		guard let appSupportURL = try? FileManager.default.applicationSupport(subDirectory: "BBEdit/Color Schemes") else {
			return [:]
		}

		var dict = [String: BBEditTheme]()

		let pairs = try? FileManager.default.namedURLs(at: appSupportURL, extension: "bbColorScheme")

		for pair in pairs ?? [] {
			guard let theme = try? BBEditTheme(contentsOf: pair.1) else { continue }

			dict[pair.0] = theme
		}

		return dict
	}

	public static var builtIn: [String: BBEditTheme] {
		guard let appUrl = NSWorkspace.shared.urlForApplication(withBundleIdentifier: "com.barebones.bbedit") else {
			return [:]
		}

		let themesURL = appUrl.appendingPathComponent("Contents/Resources/Color Schemes", isDirectory: true)

		var dict = [String: BBEditTheme]()

		let pairs = try? FileManager.default.namedURLs(at: themesURL, extension: "bbColorScheme")

		for pair in pairs ?? [] {
			guard let theme = try? BBEditTheme(contentsOf: pair.1) else { continue }

			dict[pair.0] = theme
		}

		return dict
	}

	public static var all: [String: BBEditTheme] {
		builtIn.merging(userInstalled, uniquingKeysWith: { $1 })
	}
}
#endif

extension Scanner {
	func scanCGFloat() -> CGFloat? {
		scanFloat(representation: .decimal).map(CGFloat.init)
	}

	func scanCGFloatQuad() -> (CGFloat, CGFloat, CGFloat, CGFloat)? {
		guard let a = scanCGFloat() else { return nil }
		guard scanString(",") != nil else { return nil }
		guard let b = scanCGFloat() else { return nil }
		guard scanString(",") != nil else { return nil }
		guard let c = scanCGFloat() else { return nil }
		guard scanString(",") != nil else { return nil }
		guard let d = scanCGFloat() else { return nil }

		return (a, b, c, d)
	}
}

extension BBEditTheme: Styling {
	private func platformColor(for value: String?) -> PlatformColor? {
		guard let value else { return nil }

		let scanner = Scanner(string: value)
		scanner.charactersToBeSkipped = .whitespaces

		if scanner.scanString("rgba(") != nil {
			guard let quad = scanner.scanCGFloatQuad() else { return nil }

			return PlatformColor(red: quad.0, green: quad.1, blue: quad.2, alpha: quad.3)
		}

		if scanner.scanString("hsla(") != nil {
			guard let quad = scanner.scanCGFloatQuad() else { return nil }

			return PlatformColor(hue: quad.0, saturation: quad.1, brightness: quad.2, alpha: quad.3)
		}

		return nil
	}

	public func style(for query: Query) -> Style {
		switch query.key {
		case .editor(.background):
			let color = platformColor(for: backgroundColor) ?? .red

			return Style(color: color, font: nil)
		case .syntax(.text):
			let color = platformColor(for: syntaxColors["com.barebones.bblm.code"]) ?? .black

			return Style(color: color, font: nil)
		default:
			return Style(color: .red, font: nil)
		}
	}

	public var supportedVariants: Set<Variant> {
		let color = platformColor(for: backgroundColor) ?? .white
		let isDark = color.relativeLuminance < 0.5

		return isDark ? [.init(colorScheme: .dark)] : [.init(colorScheme: .light)]
	}
}
