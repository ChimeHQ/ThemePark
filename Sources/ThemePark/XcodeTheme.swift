import Foundation

public struct XcodeTheme: Codable, Hashable, Sendable {
	public let version: Int
	public let sourceTextBackground: String
	public let selection: String
	public let markupTextNormal: String
	public let insertionPoint: String
	public let invisibles: String
	public let syntaxColors: [String: String]

	enum CodingKeys: String, CodingKey {
		case version = "DVTFontAndColorVersion"
		case markupTextNormal = "DVTMarkupTextNormalColor"
		case syntaxColors = "DVTSourceTextSyntaxColors"
		case sourceTextBackground = "DVTSourceTextBackground"
		case selection = "DVTSourceTextSelectionColor"
		case insertionPoint = "DVTSourceTextInsertionPointColor"
		case invisibles = "DVTSourceTextInvisiblesColor"
	}

	public init(with data: Data) throws {
		let decoder = PropertyListDecoder()

		self = try decoder.decode(Self.self, from: data)
	}

	public init(contentsOf url: URL) throws {
		let data = try Data(contentsOf: url, options: [])
		try self.init(with: data)
	}
}

#if canImport(AppKit) && !targetEnvironment(macCatalyst)
import AppKit

extension XcodeTheme {
	private static func xcodeThemes(in directoryURL: URL) -> [String: XcodeTheme] {
		guard let themeUrls = try? FileManager.default.contentsOfDirectory(at: directoryURL, includingPropertiesForKeys: nil) else {
			return [:]
		}

		var themes = [String: XcodeTheme]()

		for url in themeUrls {
			guard url.pathExtension == "xccolortheme" else { continue }

			if let theme = try? XcodeTheme(contentsOf: url) {
				let name = url.deletingPathExtension().lastPathComponent

				themes[name] = theme
			}
		}

		return themes
	}

	public static var userInstalled: [String: XcodeTheme] {
		let manager = FileManager.default

		let libaryUrl = try? manager.url(for: .libraryDirectory, in: .userDomainMask, appropriateFor: nil, create: false)

		guard let parentUrl = libaryUrl?.appendingPathComponent("/Developer/Xcode/UserData/FontAndColorThemes", isDirectory: true) else {
			return [:]
		}

		return xcodeThemes(in: parentUrl)
	}

	private static let builtInThemeDirectories = [
		"Contents/SharedFrameworks/DVTUserInterfaceKit.framework/Versions/Current/Resources/FontAndColorThemes",
		//		"Contents/SharedFrameworks/SourceEditor.framework/Versions/Current/Resources",
		//		"Contents/PlugIns/GPUDebugger.ideplugin/Contents/Frameworks/GPUToolsAdvancedUI.framework/Versions/Current/Resources"
	]

	public static var builtIn: [String: XcodeTheme] {
		guard let appUrl = NSWorkspace.shared.urlForApplication(withBundleIdentifier: "com.apple.dt.Xcode") else {
			return [:]
		}

		var themes = [String: XcodeTheme]()

		for parentPath in builtInThemeDirectories {
			let parentURL = appUrl.appendingPathComponent(parentPath, isDirectory: true)

			let newThemes = xcodeThemes(in: parentURL)

			themes.merge(newThemes, uniquingKeysWith: { $1 })
		}

		return themes
	}

	public static var all: [String: XcodeTheme] {
		builtIn.merging(userInstalled, uniquingKeysWith: { $1 })
	}
}
#endif

extension PlatformColor {
	convenience init?(componentsString: String) {
		let components = componentsString
			.split(separator: " ")
			.compactMap({ Float($0) })
			.map({ CGFloat($0) })

		guard components.count == 4 else {
			return nil
		}

		self.init(
			red: components[0],
			green: components[1],
			blue: components[2],
			alpha: components[3]
		)
	}
}

extension XcodeTheme: Styling {
	public func syntaxColor(for name: String) -> PlatformColor? {
		syntaxColors[name]
			.flatMap { PlatformColor(componentsString: $0) }
	}

	private var fallbackForegroundColor: PlatformColor {
#if os(macOS)
		syntaxColor(for: "xcode.syntax.plain") ?? .labelColor
#endif
	}

	private var fallbackBackgroundColor: PlatformColor {
#if os(macOS)
		PlatformColor(componentsString: sourceTextBackground) ?? .windowBackgroundColor
#endif
	}

	private func syntaxStyle(for name: String) -> Style {
		let color = syntaxColor(for: name) ?? fallbackForegroundColor

		return Style(color: color, font: nil)
	}

	public func style(for query: Query) -> Style {
		switch query.key {
		case .editor(.background), .gutter(.background):
			let color = fallbackBackgroundColor

			return Style(color: color, font: nil)
		case .editor(.cursor):
			let color = PlatformColor(componentsString: insertionPoint) ?? fallbackForegroundColor

			return Style(color: color, font: nil)
		case .editor(.accessoryForeground):
			return syntaxStyle(for: "xcode.syntax.plain")
		case .editor(.accessoryBackground):
			let color = fallbackBackgroundColor.emphasize(by: 0.4)

			return Style(color: color)
		case .syntax(.comment(_)):
			return syntaxStyle(for: "xcode.syntax.comment")
		case .syntax(.literal(.string(_))):
			return syntaxStyle(for: "xcode.syntax.string")
		case .syntax(.keyword(_)):
			return syntaxStyle(for: "xcode.syntax.keyword")
		case .syntax(.text), .gutter(.label):
			return syntaxStyle(for: "xcode.syntax.plain")
		case .syntax(.identifier(.variable)):
			return syntaxStyle(for: "xcode.syntax.identifier.variable")
		case .syntax(.literal(.number(_))):
			return syntaxStyle(for: "xcode.syntax.number")
		case .syntax(.identifier(.type)):
			return syntaxStyle(for: "xcode.syntax.identifier.type")
		case .syntax(.invisible):
			let color = PlatformColor(componentsString: invisibles) ?? fallbackForegroundColor

			return Style(color: color, font: nil)
		case .syntax(_):
			return syntaxStyle(for: "xcode.syntax.plain")
		}
	}

	public var supportedVariants: Set<Variant> {
		let color = PlatformColor(componentsString: sourceTextBackground) ?? .white
		let isDark = color.relativeLuminance < 0.5

		return isDark ? [.init(colorScheme: .dark)] : [.init(colorScheme: .light)]
	}
}

public struct XcodeVariantTheme {
	public let name: String
	public let base: XcodeTheme
	public let dark: XcodeTheme?

	public init(name: String, base: XcodeTheme, dark: XcodeTheme?) {
		self.name = name
		self.base = base
		self.dark = dark
	}

	public static var all: [XcodeVariantTheme] {
		let allThemes = XcodeTheme.all

		let lightVariants = allThemes.keys.filter({ $0.hasSuffix(" (Light)") })
		let baseNames = lightVariants.map({ String($0.dropLast(8)) })

		var variants = [XcodeVariantTheme]()

		for name in baseNames {
			let light = allThemes[name + " (Light)"]!
			let dark = allThemes[name + " (Dark)"]

			variants.append(XcodeVariantTheme(name: name, base: light, dark: dark))
		}

		for (name, theme) in allThemes {
			if name.hasSuffix("(Light)") || name.hasSuffix("(Dark)") {
				continue
			}

			variants.append(XcodeVariantTheme(name: name, base: theme, dark: nil))
		}

		return variants
	}
}

extension XcodeVariantTheme: Styling {
	public func style(for query: Query) -> Style {
		switch query.context.variant.colorScheme {
		case .dark:
			dark?.style(for: query) ?? base.style(for: query)
		case .light:
			base.style(for: query)
		@unknown default:
			base.style(for: query)
		}
	}

	public var supportedVariants: Set<Variant> {
		if dark != nil {
			return [.init(colorScheme: .dark), .init(colorScheme: .light)]
		}

		return base.supportedVariants
	}
}
