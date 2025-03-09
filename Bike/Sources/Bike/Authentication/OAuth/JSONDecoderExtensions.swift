import Foundation

public extension JSONDecoder.DateDecodingStrategy {
    /// The strategy that formats dates according to the ISO 8601 standard, supporting both dates with and without
    /// fractional seconds.
    ///
    /// The `iso8601` date decoding strategy provided by Foundation can only handle dates without fractional seconds.
    static var iso8601WithFractionalSeconds: JSONDecoder.DateDecodingStrategy {
        .custom { decoder -> Date in
            let container = try decoder.singleValueContainer()
            let string = try container.decode(String.self)
            let formatter = ISO8601DateFormatter()
            formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

            guard let date = formatter.date(from: string) else {
                // Throw an error similar to `DateDecodingStrategy.iso8601`.
                let debugDescription = """
                Expected date string to be ISO8601-formatted (with or without fractional seconds).
                """
                let context = DecodingError.Context(codingPath: decoder.codingPath, debugDescription: debugDescription)

                throw DecodingError.dataCorrupted(context)
            }

            return date
        }
    }
}
