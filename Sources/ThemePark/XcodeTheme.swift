import Foundation

public struct XcodeTheme: Codable {
	public let version: Int
	public let sourceTextBackground: String
	public let markupTextNormalColor: String
	public let syntaxColors: [String: String]

	enum CodingKeys: String, CodingKey {
		case version = "DVTFontAndColorVersion"
		case markupTextNormalColor = "DVTMarkupTextNormalColor"
		case syntaxColors = "DVTSourceTextSyntaxColors"
		case sourceTextBackground = "DVTSourceTextBackground"
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

#if canImport(AppKit)
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

extension XcodeTheme: Styling {
	public func style(for query: Query) -> Style {
		switch query {
		case .editorBackground:
			let colorComponents = sourceTextBackground
				.split(separator: " ")
				.compactMap({ Float($0) })
				.map({ CGFloat($0) })

			let color = Color(
				red: colorComponents[0],
				green: colorComponents[1],
				blue: colorComponents[2],
				alpha: colorComponents[3]
			)

			return Style(font: nil, color: color)
		default:
			return Style(font: nil, color: Color.black)
		}
	}
}
