// swift-tools-version: 5.9

import PackageDescription

let package = Package(
	name: "ThemePark",
	platforms: [
		.macOS(.v10_15),
		.iOS(.v13),
		.tvOS(.v13),
		.watchOS(.v6),
		.macCatalyst(.v13),
		.visionOS(.v1),
	],
	products: [
		.library(name: "ThemePark", targets: ["ThemePark"]),
	],
	dependencies: [
		.package(url: "https://github.com/raymondjavaxx/ColorToolbox", from: "1.1.0"),
	],
	targets: [
		.target(name: "ThemePark", dependencies: ["ColorToolbox"]),
		.testTarget(
			name: "ThemeParkTests",
			dependencies: ["ThemePark"],
			resources: [.copy("Resources")]
		),
	]
)

let swiftSettings: [SwiftSetting] = [
	.enableExperimentalFeature("StrictConcurrency"),
	.enableUpcomingFeature("DisableOutwardActorInference"),
]

for target in package.targets {
	var settings = target.swiftSettings ?? []
	settings.append(contentsOf: swiftSettings)
	target.swiftSettings = settings
}
