// swift-tools-version: 5.9

import PackageDescription

let package = Package(
	name: "ThemePark",
	platforms: [
		.macOS(.v11),
		.iOS(.v13),
		.tvOS(.v14),
		.watchOS(.v7),
		.macCatalyst(.v14),
		.visionOS(.v1),
	],
	products: [
		.library(name: "ThemePark", targets: ["ThemePark"]),
	],
	dependencies: [
		.package(url: "https://github.com/raymondjavaxx/ColorToolbox", from: "1.0.1"),
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
