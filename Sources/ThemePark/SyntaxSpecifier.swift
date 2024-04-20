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

	public enum Entity: Hashable, Sendable {
		case variable
		case constant
		case function
		case property
		case parameter
	}

	case text
	case keyword(Keyword?)
	case type
	case literal(Literal?)
	case comment(Comment?)
	case entity(Entity?)
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
		"constructor": .keyword(.definition(.constructor)),
		"float": .literal(.number(.float)),
		"function": .keyword(.definition(.function)),
		"function.call": .keyword(.operator(.call(.function))),
		"function.macro": .keyword(.operator(.call(.macro))),
		"include": .keyword(.import),
		"keyword": .keyword(nil),
		"keyword.function": .keyword(.definition(.function)),
		"keyword.operator": .keyword(.operator(nil)),
		"keyword.return": .keyword(.control),
		"label": .context,
		"method": .keyword(.definition(.method)),
		"number": .literal(.number(nil)),
		"operator": .keyword(.operator(nil)),
		"parameter": .entity(.parameter),
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
		"type": .type,
		"variable": .entity(.variable),
		"variable.builtin": .entity(.variable),
	]
}