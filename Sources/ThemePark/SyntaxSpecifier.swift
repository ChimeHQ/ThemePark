import Foundation

public enum SyntaxSpecifier: Hashable, Sendable, Codable {
	public enum Operator: Hashable, Sendable, Codable {
		public enum Call: Hashable, Sendable, Codable, CaseIterable {
			case function
			case method
			case macro
		}

		case call(Call?)
	}

	public enum Definition: Hashable, Sendable, Codable, CaseIterable {
		case function
		case method
		case macro
		case constructor
		case property
	}

	public enum Keyword: Hashable, Sendable, Codable {
		case definition(Definition?)
		case `import`
		case conditional
		case control
		case delimiter
		case `operator`(Operator?)
	}

	public enum Literal: Hashable, Sendable, Codable {
		public enum Number: Hashable, Sendable, Codable, CaseIterable {
			case float
			case integer
			case scientific
			case octal
		}

		public enum String: Hashable, Sendable, Codable, CaseIterable {
			case uri
			case escape
		}

		case string(String?)
		case number(Number?)
		case boolean
		case regularExpression
	}

	public enum Comment: Hashable, Sendable, Codable, CaseIterable {
		case line
		case block
		case semanticallySignificant
	}

	public enum Identifier: Hashable, Sendable, Codable, CaseIterable {
		case variable
		case constant
		case function
		case property
		case parameter
		case type
	}

	public enum Punctuation: Hashable, Sendable, Codable, CaseIterable {
		case delimiter
	}

	case text
	case invisible
	case keyword(Keyword?)
	case literal(Literal?)
	case comment(Comment?)
	case identifier(Identifier?)
	case context
	case `operator`(Operator?)
	case punctuation(Punctuation?)
	case definition(Definition?)

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
		"constructor": .definition(.constructor),
		"comment": .comment(nil),
		"float": .literal(.number(.float)),
		"function": .definition(.function),
		"function.call": .operator(.call(.function)),
		"function.macro": .operator(.call(.macro)),
		"function.method": .definition(.method),
		"include": .keyword(.import),
		"keyword": .keyword(nil),
		"keyword.function": .keyword(.definition(.function)),
		"keyword.operator": .keyword(.operator(nil)),
		"keyword.return": .keyword(.control),
		"label": .context,
		"method": .definition(.method),
		"number": .literal(.number(nil)),
		"operator": .operator(nil),
		"parameter": .identifier(.parameter),
		"property": .identifier(.property),
		"punctuation.delimiter": .punctuation(.delimiter),
		"punctuation.special": .punctuation(nil),
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

extension SyntaxSpecifier: CaseIterable {
	public static var allCases: [SyntaxSpecifier] {
		let allKeywords = SyntaxSpecifier.Keyword.allCases.map { SyntaxSpecifier.keyword($0) } + [.keyword(nil)]
		let allLiterals = SyntaxSpecifier.Literal.allCases.map { SyntaxSpecifier.literal($0) } + [.literal(nil)]
		let allComments = SyntaxSpecifier.Comment.allCases.map { SyntaxSpecifier.comment($0) } + [.comment(nil)]
		let allIdentifiers = SyntaxSpecifier.Identifier.allCases.map { SyntaxSpecifier.identifier($0) } + [.identifier(nil)]
		let allOperators = SyntaxSpecifier.Operator.allCases.map { SyntaxSpecifier.operator($0) } + [.operator(nil)]
		let allPunctuation = SyntaxSpecifier.Punctuation.allCases.map { SyntaxSpecifier.punctuation($0) } + [.punctuation(nil)]
		let allDefinitions = SyntaxSpecifier.Definition.allCases.map { SyntaxSpecifier.definition($0) } + [.definition(nil)]

		let base: [SyntaxSpecifier] = [
			.text,
			.invisible,
			.context
		]

		return base + allKeywords + allLiterals + allComments + allIdentifiers + allOperators + allPunctuation + allDefinitions
	}
}

extension SyntaxSpecifier.Operator: CaseIterable {
	public static var allCases: [SyntaxSpecifier.Operator] {
		let allCalls = Self.Call.allCases.map { Self.call($0) } + [.call(nil)]

		return allCalls
	}
}

extension SyntaxSpecifier.Keyword: CaseIterable {
	public static var allCases: [SyntaxSpecifier.Keyword] {
		let allOperators = SyntaxSpecifier.Operator.allCases.map { Self.operator($0) } + [.operator(nil)]
		let allDefinitions = SyntaxSpecifier.Definition.allCases.map { Self.definition($0) } + [.definition(nil)]

		let base: [SyntaxSpecifier.Keyword] = [
			.conditional,
			.control,
			.import,
			.delimiter
		]

		return base + allOperators + allDefinitions
	}
}

extension SyntaxSpecifier.Literal: CaseIterable {
	public static var allCases: [SyntaxSpecifier.Literal] {
		let allStrings = Self.String.allCases.map { Self.string($0) } + [Self.string(nil)]
		let allNumbers = Self.Number.allCases.map { Self.number($0) } + [Self.number(nil)]

		return [.boolean, .regularExpression] + allNumbers + allStrings
	}
}
