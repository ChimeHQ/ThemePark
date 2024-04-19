#if canImport(UniformTypeIdentifiers)
import UniformTypeIdentifiers

@available(macOS 11.0, iOS 14.0, watchOS 7.0, tvOS 14.0, *)
extension UTType {
	public static let textMateTheme = UTType(importedAs: "com.macromates.textmate.theme", conformingTo: .propertyList)
	public static let xcodeColorTheme = UTType(importedAs: "com.apple.dt.Xcode.color-theme", conformingTo: .propertyList)
}
#endif
