// swift-tools-version: 5.5

// WARNING:
// This file is automatically generated.
// Do not edit it by hand because the contents will be replaced.

import PackageDescription
import AppleProductTypes

let package = Package(
    name: "DeviceInfo",
    platforms: [
        .iOS("15.0")
    ],
    products: [
        .iOSApplication(
            name: "FoodTracker",
            targets: ["AppModule"],
            bundleIdentifier: "io.github.ApolloZhu.DeviceInfo",
            teamIdentifier: "2H866F22W7",
            displayVersion: "1.0",
            bundleVersion: "1",
            iconAssetName: "AppIcon",
            accentColorAssetName: "AccentColor",
            supportedDeviceFamilies: [
                .pad,
                .phone
            ],
            supportedInterfaceOrientations: [
                .portrait,
                .landscapeRight,
                .landscapeLeft,
                .portraitUpsideDown(.when(deviceFamilies: [.pad]))
            ]
        )
    ],
    dependencies: [
    ],
    targets: [
        .executableTarget(
            name: "AppModule",
            dependencies: [
            ],
            path: "."
        )
    ]
)