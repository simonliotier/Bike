import SwiftUI

public extension Image {
    // Create an image using the battery system image that most closely matches the battery percentage.
    init(batteryPercentage: Double) {
        let images = [
            0.00: "battery.0percent",
            0.25: "battery.25percent",
            0.50: "battery.50percent",
            0.75: "battery.75percent",
            1.00: "battery.100percent"
        ]

        guard let closest = images.keys.min(by: { abs($0 - batteryPercentage) < abs($1 - batteryPercentage) }),
              let systemName = images[closest] else {
            self.init("")
            return
        }

        self.init(systemName: systemName)
    }
}
