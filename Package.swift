// swift-tools-version: 5.7

import PackageDescription

let package = Package(
	name: "ThemePark",
	products: [
		.library(name: "ThemePark", targets: ["ThemePark"]),
	],
	targets: [
		.target(name: "ThemePark"),
		.testTarget(name: "ThemeParkTests", dependencies: ["ThemePark"]),
	]
)
