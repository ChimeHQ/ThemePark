import Foundation

#if canImport(UniformTypeIdentifiers)
import UniformTypeIdentifiers

@available(macOS 11.0, iOS 14.0, watchOS 7.0, tvOS 14.0, *)
extension UTType {
	public static let textMateTheme = UTType(importedAs: "com.macromates.textmate.theme", conformingTo: .propertyList)
}
#endif

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
}
