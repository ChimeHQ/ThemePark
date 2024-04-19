import Foundation

#if canImport(UIKit)
import UIKit

public typealias Color = UIColor
#elseif canImport(AppKit)
import AppKit

public typealias Color = NSColor
#endif

public protocol ColorDecoder {
	func color(hex: String) -> Color?
}

public struct Style : Hashable {
	public let font: String?
	public let color: Color

	public init(font: String?, color: Color) {
		self.font = font
		self.color = color
	}
}

public enum Query : Hashable, Sendable {
	case editorBackground

	case syntaxDefault
	case syntax([String])
}

public protocol Styling {
	func style(for query: Query) -> Style
}

