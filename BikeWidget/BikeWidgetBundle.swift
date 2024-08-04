import WidgetKit
import SwiftUI

@main
struct BikeWidgetBundle: WidgetBundle {
    var body: some Widget {
        BikeLocationWidget()
        BikeBatteryWidget()
    }
}
