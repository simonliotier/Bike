import SwiftUI
import WidgetKit

@main
struct BikeWidgetBundle: WidgetBundle {
    var body: some Widget {
        BikeLocationWidget()
        BikeBatteryWidget()
    }
}
