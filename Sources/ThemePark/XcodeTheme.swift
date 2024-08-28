import Foundation

public struct XcodeTheme: Codable, Hashable, Sendable {
	public let version: Int
	public let sourceTextBackground: String
	public let selection: String
	public let markupTextNormalColor: String
	public let markupTextNormalFont: String
	public let insertionPoint: String
	public let invisibles: String
	public let syntaxColors: [String: String]
	public let syntaxFonts: [String: String]

	enum CodingKeys: String, CodingKey {
		case version = "DVTFontAndColorVersion"
		case markupTextNormalColor = "DVTMarkupTextNormalColor"
		case markupTextNormalFont = "DVTMarkupTextNormalFont"
		case syntaxColors = "DVTSourceTextSyntaxColors"
		case syntaxFonts = "DVTSourceTextSyntaxFonts"
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
	private static func xcodeThemes(in directoryURL: URL) -> [URL] {
		guard let themeUrls = try? FileManager.default.contentsOfDirectory(at: directoryURL, includingPropertiesForKeys: nil) else {
			return []
		}

		return themeUrls.filter { $0.pathExtension == "xccolortheme" }
	}

	public static var userInstalled: [URL] {
		let manager = FileManager.default

		let libaryUrl = try? manager.url(for: .libraryDirectory, in: .userDomainMask, appropriateFor: nil, create: false)

		guard let parentUrl = libaryUrl?.appendingPathComponent("/Developer/Xcode/UserData/FontAndColorThemes", isDirectory: true) else {
			return []
		}

		return xcodeThemes(in: parentUrl)
	}

	private static let builtInThemeDirectories = [
		"Contents/SharedFrameworks/DVTUserInterfaceKit.framework/Versions/Current/Resources/FontAndColorThemes",
		//		"Contents/SharedFrameworks/SourceEditor.framework/Versions/Current/Resources",
		//		"Contents/PlugIns/GPUDebugger.ideplugin/Contents/Frameworks/GPUToolsAdvancedUI.framework/Versions/Current/Resources"
	]

	public static var builtIn: [URL] {
		guard let appUrl = NSWorkspace.shared.urlForApplication(withBundleIdentifier: "com.apple.dt.Xcode") else {
			return []
		}

		return builtInThemeDirectories.flatMap { path in
			let parentURL = appUrl.appendingPathComponent(path, isDirectory: true)

			return xcodeThemes(in: parentURL)
		}
	}

	public static var all: [URL] {
		builtIn + userInstalled
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

extension PlatformFont {
	convenience init?(componentsString: String) {
		let components = componentsString
			.components(separatedBy: " - ")

		guard components.count == 2,
			  let fontSize = Float(components[1])
		else {
			return nil
		}

		self.init(
			name: components[0],
			size: CGFloat(fontSize)
		)
	}
}

extension XcodeTheme: Styling {
	public func syntaxColor(for name: String) -> PlatformColor? {
		syntaxColors[name]
			.flatMap { PlatformColor(componentsString: $0) }
	}

	public func syntaxFont(for name: String) -> PlatformFont? {
		syntaxFonts[name]
			.flatMap { PlatformFont(componentsString: $0) }
	}

	private var fallbackForegroundColor: PlatformColor {
		syntaxColor(for: "xcode.syntax.plain") ?? .fallbackForegroundColor
	}

	private var fallbackFont: PlatformFont {
		syntaxFont(for: "xcode.syntax.plain") ?? PlatformFont.fallbackFont
	}

	private var fallbackBackgroundColor: PlatformColor {
		PlatformColor(componentsString: sourceTextBackground) ?? .fallbackBackgroundColor
	}

	private func syntaxStyle(for name: String) -> Style {
		let color = syntaxColor(for: name) ?? fallbackForegroundColor
		let font = syntaxFont(for: name) ?? fallbackFont

		return Style(color: color, font: font)
	}

	public func style(for query: Query) -> Style {
		switch query.key {
		case .editor(.background), .gutter(.background):
			let color = fallbackBackgroundColor
			let font = fallbackFont

			return Style(color: color, font: font)
		case .editor(.cursor):
			let color = PlatformColor(componentsString: insertionPoint) ?? fallbackForegroundColor
			let font = PlatformFont(componentsString: insertionPoint) ?? fallbackFont

			return Style(color: color, font: font)
		case .editor(.accessoryForeground):
			return syntaxStyle(for: "xcode.syntax.plain")
		case .editor(.accessoryBackground):
			let color = fallbackBackgroundColor.emphasize(by: 0.4)

			return Style(color: color)
		case .syntax(.comment(_)):
			return syntaxStyle(for: "xcode.syntax.comment")
		case .syntax(.literal(.string(.uri))):
			return syntaxStyle(for: "xcode.syntax.url")
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
		case .syntax(.definition(.method)), .syntax(.definition(.function)), .syntax(.definition(.constructor)), .syntax(.definition(.property)):
			return syntaxStyle(for: "xcode.syntax.identifier.function")
		case .syntax(.definition(.macro)):
			return syntaxStyle(for: "xcode.syntax.identifier..macro")
		case .syntax(.invisible):
			let color = PlatformColor(componentsString: invisibles) ?? fallbackForegroundColor
			let font = PlatformFont(componentsString: invisibles) ?? fallbackFont

			return Style(color: color, font: font)
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

//public struct XcodeVariantTheme {
//	public let name: String
//	public let base: URL
//	public let dark: URL?
//
//	public init(name: String, base: URL, dark: URL?) {
//		self.name = name
//		self.base = base
//		self.dark = dark
//	}
//
//#if canImport(AppKit) && !targetEnvironment(macCatalyst)
//	public static var all: [XcodeVariantTheme] {
//		let allThemes = XcodeTheme.all
//
//		let lightVariants = allThemes.filter { $0.path.hasSuffix(" (Light).xccolortheme") }
//		let baseNames = lightVariants.map({ String($0.dropLast(8)) })
//
//		var variants = [XcodeVariantTheme]()
//
//		for name in baseNames {
//			let light = allThemes[name + " (Light).xccolortheme"]!
//			let dark = allThemes[name + " (Dark).xccolortheme"]
//
//			variants.append(XcodeVariantTheme(name: name, base: light, dark: dark))
//		}
//
//		for (name, theme) in allThemes {
//			if name.hasSuffix("(Light)") || name.hasSuffix("(Dark)") {
//				continue
//			}
//
//			variants.append(XcodeVariantTheme(name: name, base: theme, dark: nil))
//		}
//
//		return variants
//	}
//#endif
//}
//
//extension XcodeVariantTheme: Styling {
//	public func style(for query: Query) -> Style {
//		switch query.context.variant.colorScheme {
//		case .dark:
//			dark?.style(for: query) ?? base.style(for: query)
//		case .light:
//			base.style(for: query)
//		@unknown default:
//			base.style(for: query)
//		}
//	}
//
//	public var supportedVariants: Set<Variant> {
//		if dark != nil {
//			return [.init(colorScheme: .dark), .init(colorScheme: .light)]
//		}
//
//		return base.supportedVariants
//	}
//}
