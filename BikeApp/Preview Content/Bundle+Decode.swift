import Foundation
#if os(iOS)
    import UIKit
#else
    import AppKit
#endif

extension Bundle {
    /// Return an object of the given type by decoding a JSON stored in an asset catalog.
    func decodeAsset<T: Decodable>(_ type: T.Type = T.self,
                                   named name: String,
                                   dateDecodingStrategy: JSONDecoder.DateDecodingStrategy = .deferredToDate,
                                   keyDecodingStrategy: JSONDecoder.KeyDecodingStrategy = .useDefaultKeys) throws -> T {
        guard let asset = NSDataAsset(name: name) else {
            throw AssetError.assetNotFound
        }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = dateDecodingStrategy
        decoder.keyDecodingStrategy = keyDecodingStrategy

        return try decoder.decode(T.self, from: asset.data)
    }
}

enum AssetError: Error {
    case assetNotFound
}
