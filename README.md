<div align="center">

[![Build Status][build status badge]][build status]
[![Platforms][platforms badge]][platforms]

</div>

# ThemePark
A Swift library for working with syntax highlighting/IDE themes

Pretty much every editor has its own theming system. I'd love a package that could be used to intrepret a bunch of different themes for interoperability. I'm not sure how feasible this would be for all the things a theme can control, but I thought at a minimum it could be handy for syntax highlighting.

Supports:

- TextMate `.tmTheme` with `UTType.textMateTheme`
- Xcode `.xccolortheme` with `UTType.xcodeColorTheme`

> [!WARNING]
> This is currently very WIP.

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
