import Foundation
import SwiftUI

/// Provide unified APIs for images on all platforms.

#if canImport(UIKit)
    import UIKit
#endif

#if canImport(AppKit)
    import AppKit
#endif

#if os(iOS) || os(watchOS)
    public typealias OSImage = UIImage
#elseif os(macOS)
    public typealias OSImage = NSImage
    extension OSImage: @unchecked @retroactive Sendable {}
#endif

public extension Image {
    init(osImage: OSImage) {
        #if os(iOS) || os(watchOS)
            self.init(uiImage: osImage)
        #endif
        #if os(macOS)
            self.init(nsImage: osImage)
        #endif
    }
}

#if os(macOS)
    public extension NSImage {
        func pngData() -> Data? {
            guard let cgImage = cgImage(forProposedRect: nil, context: nil, hints: nil) else {
                print("Failed to create CGImage from NSImage.")
                return nil
            }

            let bitmapRep = NSBitmapImageRep(cgImage: cgImage)
            bitmapRep.size = size

            // Convert the bitmap representation to PNG data
            guard let pngData = bitmapRep.representation(using: .png, properties: [:]) else {
                print("Failed to convert CGImage to PNG data.")
                return nil
            }

            return pngData
        }
    }
#endif

public extension ImageRenderer {
    @MainActor
    var osImage: OSImage? {
        #if os(iOS) || os(watchOS)
            return uiImage
        #elseif os(macOS)
            return nsImage
        #endif
    }
}
