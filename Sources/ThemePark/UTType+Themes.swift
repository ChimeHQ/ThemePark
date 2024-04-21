#if canImport(UniformTypeIdentifiers)
import UniformTypeIdentifiers

@available(macOS 11.0, iOS 14.0, watchOS 7.0, tvOS 14.0, *)
extension UTType {
	public static let textMateTheme = UTType(importedAs: "com.macromates.textmate.theme", conformingTo: .propertyList)
	public static let xcodeColorTheme = UTType(importedAs: "com.apple.dt.Xcode.color-theme", conformingTo: .propertyList)

	// this is actually a propertyList, but bbedit does not declare it that way, and I'm unsure the implications are of fixing that here
	public static let bbeditColorScheme = UTType(importedAs: "com.barebones.bbedit.color-scheme")
	public static let bbeditLegacyColorScheme = UTType(importedAs: "com.barebones.bbedit.legacy-color-scheme")
}
#endif
