# SkinSmoothingFilter

A lightweight SkinSmoothing Filter using Metal and CoreImage.


# Requirements

iOS 15+, macOS 11+

# Installation

You can add SkinSmoothingFilter to your project via Swift Package Manager by adding the following to your `Package.swift` file:

```swift
dependencies: [
    .package(url: "https://github.com/shima11/SkinSmoothingFilter.git", .upToNextMajor(from: "1.0.0"))
]
```

# Usage

To use the SkinSmoothingFilter, you first need to import the package into your project:

```swift
import SkinSmoothingFilter
```

Then, create an instance of SkinSmoothingFilter, set your desired parameters, and process your images like so:

```swift
let filter = SkinSmoothingFilter()
filter.inputImage = ciImage // Your input CIImage
filter.inputAmount = inputAmount // Smoothing amount
filter.inputSharpness = inputSharpness // Image sharpness
filter.inputRadius = inputRadius // Blur radius

let result = filter.outputImage // Processed CIImage
```

# Contributing

Contributions are welcome! Please feel free to submit a pull request or open an issue if you have any ideas, bug reports, or suggestions.

# License

SkinSmoothingFilter is available under the MIT license. See the LICENSE file for more info.
