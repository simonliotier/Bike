import BikeCore
import SwiftUI

/// Wrapper around the data that are displayed in the `BideDetails` popover.
struct BikeDetails {
    let lastRides: [Ride]
    let weekStats: [Stat]
}
