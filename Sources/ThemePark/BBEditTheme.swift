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
