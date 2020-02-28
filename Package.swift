// swift-tools-version:5.0

import PackageDescription

let package = Package(
    name: "IHKeyboardAvoiding",
    platforms: [
        .iOS(.v8)
    ],
    products: [
        .library(name: "IHKeyboardAvoiding", targets: ["IHKeyboardAvoiding"])
    ],
    targets: [
        .target(name: "IHKeyboardAvoiding", path: ".", sources: ["Sources"])
    ]
)
