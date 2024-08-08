import Contacts
import CoreLocation
import Foundation
import MapKit
import SwiftUI
import WidgetKit

// MARK: - Bike Battery

extension BikeBatteryWidget.Entry.State.Content {
    static let preview = Self(name: "Elops 920E", batteryPercentage: 0.62)
}

// MARK: - Bike location

extension BikeLocationWidget.Entry.State.Content {
    static func preview(for family: WidgetFamily) -> Self {
        let date = Calendar.current.date(byAdding: .hour, value: -10, to: .now) ?? .now

        return .init(date: date,
                     placemark: .preview,
                     batteryPercentage: 0.62,
                     name: "Elops 920E",
                     mapSnapshot: .preview(for: family))
    }
}

extension BikeLocationWidget.Entry.State.Content.MapSnapshot {
    static func preview(for family: WidgetFamily) -> Self {
        switch family {
        case .systemSmall:
            .init(resource: .bikeLocationSystemSmall, point: .init(x: 110.6, y: 79.0))
        case .systemMedium:
            .init(resource: .bikeLocationSystemMedium, point: .init(x: 270.4, y: 79.0))
        default:
            .init(lightImage: OSImage(), darkImage: OSImage(), bikeMarkerPosition: .zero)
        }
    }

    private init(resource: ImageResource, point: CGPoint) {
        let image = OSImage(resource: resource)
        #if os(iOS)
            let asset = image.imageAsset
            lightImage = asset?.image(with: .init(userInterfaceStyle: .light)) ?? OSImage(resource: resource)
            darkImage = asset?.image(with: .init(userInterfaceStyle: .dark)) ?? OSImage(resource: resource)
        #endif
        #if os(macOS)
            // Does not matter as previews are not supported for macOS widgets.
            lightImage = image
            darkImage = image
        #endif
        bikeMarkerPosition = point
    }
}

extension CLPlacemark {
    static let preview = CLPlacemark(location: .preview,
                                     name: CNPostalAddress.preview.street,
                                     postalAddress: .preview)
}

extension CLLocation {
    static let preview = CLLocation(latitude: 47.21342, longitude: -1.54440)
}

extension CNPostalAddress {
    static var preview: CNPostalAddress {
        let address = CNMutablePostalAddress()
        address.street = "7 rue de Valmy"
        address.city = "Nantes"
        address.state = "Pays de la Loire"
        address.postalCode = "44000"
        address.country = "France"
        address.isoCountryCode = "FR"
        address.subAdministrativeArea = "Loire-Atlantique"
        address.subLocality = ""
        return address
    }
}

// MARK: - Error

struct PreviewError: Error {}
