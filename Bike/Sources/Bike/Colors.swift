import Foundation
import SwiftUI

/// Expose Asset Catalog generated colors as `ShapeStyle`.
public extension ShapeStyle where Self == Color {
    static var decathlon: Color { Color(.decathlon) }
    static var pin: Color { Color(.pin) }
}
