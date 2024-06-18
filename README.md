<p align="center">
    <a href="https://github.com/pEEcor/swift-foundation-extras/actions/workflows/ci.yml">
        <img src="https://github.com/pEEcor/swift-foundation-extras/actions/workflows/ci.yml/badge.svg?branch=main"
    </a>
    <a href="https://codecov.io/gh/pEEcor/swift-foundation-extras" > 
    <img src="https://codecov.io/gh/pEEcor/swift-foundation-extras/graph/badge.svg?token=3MBI7HAVN5"/> 
    </a>
    <a href="https://github.com/pEEcor/swift-foundation-extras/tags">
        <img alt="GitHub tag (latest SemVer)"
             src="https://img.shields.io/github/v/tag/pEEcor/swift-foundation-extras?label=version">
    </a>
    <img src="https://img.shields.io/badge/Swift-5.10-red"
         alt="Swift: 5.10">
    <img src="https://img.shields.io/badge/Platforms-iOS%20%7C%20macOS-red"
        alt="Platforms: iOS, macOS">
    <a href="https://github.com/pEEcor/swiftui-pager/blob/main/LICENSE">
        <img alt="GitHub" 
             src="https://img.shields.io/github/license/pEEcor/swiftui-pager">
    </a>
</p>

# swift-foundation-extras

Useful extensions to the Foundation framework.

## Dislaimer

Do not rely on this package as a dependeny in your project. I try to keep breaking changes minimal
but they may occur every now and then which might be undesired for your use-case. However feel free
to use/copy anything you like.

## Overview

This library comes with a couple of tools that are often needed during app development on Apple's
platforms. It extends various existing types and also introduces new tools for:
    
- Caching
- Persistence
- Coding
- Mapping

## Installation via SPM

Add the following to you `Package.swift` description. Replace `version` with the tag of the
desired version listed in [Releases](https://github.com/pEEcor/swift-foundation-extras/releases).

```Swift
.package(url: "git@github.com:pEEcor/swift-foundation-extras.git", from: "version")
```

The exposed library is named `FoundationExtras`.

## Documentation

The latest documentation for this library is available [here][documentation].

## License

This library is released under the MIT license. See [LICENSE](LICENSE) for details.

[documentation]: https://peecor.github.io/swift-foundation-extras/main/documentation/foundationextras/
