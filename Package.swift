// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "IHKeyboardAvoiding",
    platforms: [
       .iOS(.v8)
    ],
    products: [
        .library(
            name: "IHKeyboardAvoiding",
            targets: ["IHKeyboardAvoiding"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "IHKeyboardAvoiding",
            dependencies: [], 
         path: "Sources")
    ]
)
