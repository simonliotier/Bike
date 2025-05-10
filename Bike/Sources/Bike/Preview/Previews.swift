#if !os(tvOS)
import Contacts

public extension CNPostalAddress {
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
#endif
