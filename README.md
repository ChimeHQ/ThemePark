<div align="center">

[![Build Status][build status badge]][build status]
[![Platforms][platforms badge]][platforms]
[![Documentation][documentation badge]][documentation]

</div>

# ThemePark
A Swift library for working with syntax highlighting/IDE themes

This package aims to solve two problems: reading theme definitions and making those definitions semantically-addressable.

Supports:

- TextMate `.tmTheme` with `UTType.textMateTheme`
- Xcode `.xccolortheme` with `UTType.xcodeColorTheme`
- BBEdit `.bbColorScheme` with `UTType.bbeditColorScheme`
- Loading themes from known installation sources
- Uniform, structed semantic naming of style defintions

## Installation

```swift
dependencies: [
    .package(url: "https://github.com/ChimeHQ/ThemePark", branch: "main")
],
```

## Usage

### Working with themes

TextMate themes:

```swift
import ThemePark

let url = URL(...)
let data = try Data(contentsOf: url, options: [])
let theme = try TextMateTheme(with: data)

let allInstalledThemes = TextMateTheme.all
```

Xcode Themes:

```swift
import ThemePark

let url = URL(...)
let data = try Data(contentsOf: url, options: [])
let theme = try XcodeTheme(with: data)

// [String: XcodeTheme], as XcodeTheme names are stored only on the file system
let allInstalledThemes = XcodeTheme.all

// consolidates Xcode themes by color scheme variant
let allVariants = XcodeVariantTheme.all
```

BBEdit themes:

```swift
import ThemePark

let url = URL(...)
let data = try Data(contentsOf: url, options: [])
let theme = try BBEditTheme(with: data)

let allInstalledThemes = BBEditTheme.all
```

### Resolving styles

ThemePark's `Styling` protocol can make use of the SwiftUI environment to adjust for color scheme, contrast, and hover state. You can expose this to your view heirarchy with a modifier:

```
import SwiftUI
import ThemePark

struct ThemedView: View {
    var body: some View {
        Text("themed")
            .themeSensitive()
    }
}
``` 

Executing queries on a theme:

```
let styler: any Styling = TextMateTheme.all.randomElement()!
let query = Query(key: .editorBackground, context: .init(colorScheme: .dark))

let style = styler.style(for: query)
print(style.color)
print(style.font)
```

### Color schemes

The `Variant` type captures information about color scheme and contrast. But, do you want the theme to fully customize the UI, or would you like the user's preferences to customize the theme? This is up the the client and the capabilities of the underlying `Styling` conformance. Many themes also do not support more than one variant, so it can be necessary to query that as well:

```swift
let variants = theme.supportedVariants
```

### Syntax element indentification

Most theming systems use strings to provide semantic labels for syntax elements. Eventually, this string->semantic meaning needs to be resolved. Instead of leaving this up to the client/theme designer, ThemePark uses a enum-based system for syntax element indentification. This removes all ambiguity, but can potentially expose mismatches.

This is a very common problem with tree-sitter highlight queries, which have no specification and are often completely ad-hoc.

```swift
let specifier = SyntaxSpecifier(highlightsQueryCapture: catpureName)
```

## Contributing and Collaboration

I would love to hear from you! Issues, Discussions, or pull requests work great.

I prefer collaboration, and would love to find ways to work together if you have a similar project.

I prefer indentation with tabs for improved accessibility. But, I'd rather you use the system you want and make a PR than hesitate because of whitespace.

By participating in this project you agree to abide by the [Contributor Code of Conduct](CODE_OF_CONDUCT.md).

[editorconfig]: https://editorconfig.org
[build status]: https://github.com/ChimeHQ/ThemePark/actions
[build status badge]: https://github.com/ChimeHQ/ThemePark/workflows/CI/badge.svg
[platforms]: https://swiftpackageindex.com/ChimeHQ/ThemePark
[platforms badge]: https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2FChimeHQ%2FThemePark%2Fbadge%3Ftype%3Dplatforms
[documentation]: https://swiftpackageindex.com/ChimeHQ/ThemePark/main/documentation
[documentation badge]: https://img.shields.io/badge/Documentation-DocC-blue
