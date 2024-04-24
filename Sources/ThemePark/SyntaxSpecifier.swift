import Foundation

public enum SyntaxSpecifier: Hashable, Sendable {
	public enum Keyword: Hashable, Sendable {
		public enum Definition: Hashable, Sendable {
			case function
			case method
			case macro
			case constructor
			case property
		}
		
		public enum Operator: Hashable, Sendable {
			public enum Call: Hashable, Sendable {
				case function
				case method
				case macro
			}

			case call(Call?)
		}

		case definition(Definition?)
		case `import`
		case conditional
		case control
		case `operator`(Operator?)
		case delimiter
	}

	public enum Literal: Hashable, Sendable {
		public enum Number: Hashable, Sendable {
			case float
			case integer
			case scientific
			case octal
		}

		public enum String: Hashable, Sendable {
			case uri
			case escape
		}

		case string(String?)
		case number(Number?)
		case boolean
		case regularExpression
	}

	public enum Comment: Hashable, Sendable {
		case line
		case block
		case semanticallySignificant
	}

	public enum Identifier: Hashable, Sendable {
		case variable
		case constant
		case function
		case property
		case parameter
		case type
	}

	case text
	case invisible
	case keyword(Keyword?)
	case literal(Literal?)
	case comment(Comment?)
	case identifier(Identifier?)
	case context

	public init?(highlightsQueryCapture name: String) {
		guard let specififer = SyntaxSpecifier.treeSitterQueryCaptureMap[name] else {
			return nil
		}

		self = specififer
	}
}

extension SyntaxSpecifier {
	private static let treeSitterQueryCaptureMap: [String: SyntaxSpecifier] = [
		"boolean": .literal(.boolean),
		"conditional": .keyword(.conditional),
		"constant": .identifier(.constant),
		"constant.builtin": .identifier(.constant),
		"constructor": .keyword(.definition(.constructor)),
		"comment": .comment(nil),
		"float": .literal(.number(.float)),
		"function": .keyword(.definition(.function)),
		"function.call": .keyword(.operator(.call(.function))),
		"function.macro": .keyword(.operator(.call(.macro))),
		"function.method": .keyword(.definition(.method)),
		"include": .keyword(.import),
		"keyword": .keyword(nil),
		"keyword.function": .keyword(.definition(.function)),
		"keyword.operator": .keyword(.operator(nil)),
		"keyword.return": .keyword(.control),
		"label": .context,
		"method": .keyword(.definition(.method)),
		"number": .literal(.number(nil)),
		"operator": .keyword(.operator(nil)),
		"parameter": .identifier(.parameter),
		"property": .keyword(.definition(.property)),
		"punctuation.delimiter": .keyword(.delimiter),
		"punctuation.special": .keyword(nil),
		"repeat": .keyword(.control),
		"string": .literal(.string(nil)),
		"string.escape": .literal(.string(.escape)),
		"string.regex": .literal(.regularExpression),
		"string.uri": .literal(.string(.uri)),
		"text.literal": .literal(.string(nil)),
		"text.reference": .context,
		"text.uri": .literal(.string(.uri)),
		"type": .identifier(.type),
		"variable": .identifier(.variable),
		"variable.builtin": .identifier(.variable),
	]
}
